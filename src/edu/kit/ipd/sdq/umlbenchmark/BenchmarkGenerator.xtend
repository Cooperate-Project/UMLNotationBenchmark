package edu.kit.ipd.sdq.umlbenchmark

import com.google.common.base.Strings
import java.io.ByteArrayInputStream
import java.io.ByteArrayOutputStream
import java.util.ArrayList
import java.util.Collections
import java.util.HashMap
import java.util.HashSet
import java.util.Iterator
import org.apache.commons.lang.RandomStringUtils
import org.eclipse.emf.common.util.Diagnostic
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.util.Diagnostician
import org.eclipse.emf.ecore.util.EcoreUtil
import org.jgrapht.Graph
import org.jgrapht.alg.FloydWarshallShortestPaths
import org.jgrapht.graph.DefaultEdge

class BenchmarkGenerator {
	
	// this package is used for all queries and for model creation
	private val EPackage rootPackage
	
	// this package is only used to query package names
	private val EPackage rootPackageOmgUml
	
	new(EPackage eclipseUML, EPackage omgUML) {
		this.rootPackage = eclipseUML
		this.rootPackageOmgUml = omgUML
	}
	
	private HashMap<EClass, ArrayList<EClass>> elementList = new HashMap
	private HashMap<EClass, Integer> elementCounter = new HashMap
	private HashSet<EObject> roots = new HashSet
	private HashSet<String> boundry = new HashSet
	val ArrayList<String> bannedElements = new ArrayList
	protected Graph<EClass, DefaultEdge> graph
	protected FloydWarshallShortestPaths<EClass, DefaultEdge> fWSP
	private EClass hauptmodellelement
	
	def createBenchmarks() {
		val packageClass = rootPackage.eAllContents.filter(EClass).findFirst[name == "Package"]
		/*
		 * Hier das gewünschte Modellelement eintragen, um Diagramme für dieses zu erzeugen
		 */
		hauptmodellelement = rootPackage.eAllContents.filter(EClass).findFirst[name == "ExtensionPoint"]
		initializeBoundries	
		graph = WarshallFloyd.warshallFloyd(rootPackage, elementList)
		fWSP = new FloydWarshallShortestPaths(graph)
		initializeGenerator(hauptmodellelement, packageClass)
		
		for (EObject root : roots) {
			EcoreUtil.resolveAll(root)
			validateEObject(root)
		}
		
		return roots
	}
	
	private static def validateEObject(EObject eObject) {
		val testEObject = saveAndLoadRootEObject(eObject)
        val Diagnostic diagnostic = Diagnostician.INSTANCE.validate(testEObject)
        if (diagnostic.getSeverity() != Diagnostic.OK) {
            printDiagnostic(diagnostic)
        }
	}
	
	private static def saveAndLoadRootEObject(EObject eobject) {
		val baos = new ByteArrayOutputStream()
		try {
			val r = new ResourceSetImpl().createResource(URI.createFileURI(RandomStringUtils.randomAlphanumeric(5)))
			r.contents.add(eobject)
			r.save(baos, Collections.EMPTY_MAP)
			r.unload
			val bais = new ByteArrayInputStream(baos.toByteArray)
			try {
				r.load(bais, Collections.EMPTY_MAP)
				return r.contents.get(0)
			} finally {
				bais.close
			}
		} finally {
			baos.close
		}
	}
	
	private static def void printDiagnostic(Diagnostic diagnostic) {
		printDiagnostic(diagnostic, 0)
	}
	
	private static def void printDiagnostic(Diagnostic diagnostic, int indentationLevel) {
		println(Strings.repeat("  ", indentationLevel) + diagnostic.getMessage());
		for (child : diagnostic.getChildren()) {
			printDiagnostic(child, indentationLevel + 1)
		}
	}
	
	
	/**
 	* Methode, die die Generierung aller Diagramme für das Hauptmodellelement "Start" startet
 	* 
 	* Zuerst wird überprüft, ob "Start" ein eindeutiges abstraktes Container-Element besitzt.
 	* Ist dies der Fall, werden alle Spezialisierungen des abstrakten Elements gesucht und 
 	* iterativ für jede Spezialisierung die Diagrammgenerierung gestartet.
 	* Ist das Hauptmodellelement selbst das Wurzelelement, so wird es direkt erzeugt und die Methode ended.
 	* In allen anderen Fällen wird das Wurzelelement erzeugt, ein Pfad gesucht, über den das Hauptmodellelement
 	* von dem Wurzelelement contained werden kann und anschließend dieser Pfad realisiert.
 	* 
 	* @param start	Das Hauptmodellelement, zu dem Diagramme erstellt werden sollen
 	* @param ziel	Das Modellelement, welches als Wurzelelement dient und alle anderen Elemente enthält
 	*/
	def private initializeGenerator(EClass start, EClass ziel) {
		var boolean containerAbstract = false
		var EClass container
		val EClass packageClass = rootPackage.eAllContents.filter(EClass).findFirst[name == "Package"]
		val tempCount = new HashMap<EClass, Integer>
		tempCount.putAll(elementCounter)
		for (EReference ref : start.EAllReferences) {
			if (ref.container && ref.EReferenceType.abstract) {
				container = ref.EReferenceType
				containerAbstract = true
			}
		}
		if (containerAbstract) {
			val allClasses = rootPackage.eAllContents.filter(EClass)
			val ArrayList<EClass> specific = findSpecialization(new ArrayList, container, allClasses)
			
			for (EClass c : specific) {
				elementCounter.clear
				elementCounter.putAll(tempCount)
				val EObject root = createElement(packageClass)
				var path = WarshallFloyd.getPath(c, ziel, graph, fWSP)
				path.add(start)
				roots.add(root)
				createContainments(start, path, root)
			}
		} else if (start == ziel) {
			roots.add(createElement(ziel))
		} else {
			val EObject root = createElement(packageClass)
			val path = WarshallFloyd.getPath(start, ziel, graph, fWSP)
			roots.add(root)
			createContainments(start, path, root)
		}	
	}
	
	def protected EObject createContainments(EClass clazz, ArrayList<EClass> path, EObject root) {
		val packageClass = rootPackage.eAllContents.filter(EClass).findFirst[name == "Package"]
		val PackagedElementReference = packageClass.getEAllReferences.findFirst[name == "packagedElement"]
		val nameAttribute = clazz.getEAllAttributes.findFirst[name == "name"]
		val o = createElement(clazz)
		var EClass vorgaenger
		
		// Bestimme Vorgängerelement
		if (clazz != packageClass) {
			vorgaenger = path.get(path.indexOf(clazz) - 1)
		}
		
		//Spezialbehandlung für "Trigger"
		if (clazz.name == "Trigger") {
			TriggerFix.fixTrigger(o, root, rootPackage, this)
		
		//Spezialbehandlung für "Reception"
		} else if (clazz.name == "Reception") {
			ReceptionFix.fixReception(o, root, rootPackage, this)
		
		// Falls Vorgänger bereits Package ist, setze die PackagedElement-Referenz
		} else if (vorgaenger == packageClass) {
			if (clazz.name == "Comment") {
				addElementToReference(root, packageClass.getEAllReferences.findFirst[name == "ownedComment"], o)
			} else {
				addElementToReference(root, PackagedElementReference, o)
			}
			
		} else if (vorgaenger != null) {
			if (clazz.name == "ExtensionPoint") {
				ExtendFix.fixExtend(o, root, this)
			} else {
				val container = createContainments(vorgaenger, path, root)
				for (EReference ref : vorgaenger.EAllContainments) {	
					if (ref.EReferenceType == clazz) {
						if (ref.name == "interfaceRealization") {
							addElementToReference(o, o.eClass.EAllReferences.findFirst[name == "client"], container)
						}
						if (nameAttribute != null && ref.EOpposite != null) {
							container.eSet(nameAttribute, ref.EOpposite.name)
						}
						if (nameAttribute != null) {
							o.eSet(nameAttribute, ref.name)
						}
						if (ref.EOpposite != null) {
							addElementToReference(o, ref.EOpposite, container)	
						}
						addElementToReference(container, ref, o)
					}
				}
			} 
		}
		createReferences(o, root)
		return o
	}
	
	// Auswahl von Spezialisierungen, falls Modellelement abstrakt ist
	def protected ArrayList<EClass> findSpecialization(ArrayList<EClass> l, EClass type, Iterator<EClass> allClasses) {
		val ArrayList<EClass> tempL = new ArrayList
		tempL.addAll(allClasses.toList)
		
		for (EClass c : tempL) {
			if (c.EAllSuperTypes.contains(type)) {
				if (c.abstract) {
					for (EClass e : findSpecialization(l, type, allClasses)) {
						if (!l.contains(e)) {
							l.add(e)
						}
					}
				} else {
					if (boundry.contains(c.packageName)) {
						if (!l.contains(c)) {
							if (!bannedElements.contains(c.name))
							l.add(c)
						}
					}	
				}
			}
		}
		return l
	}
	
	// Erzeugt alle Referenzen, die nicht mit den Elternelementen zusammenhängen
	def private boolean createReferences(EObject o, EObject root) {
		val packageClass = rootPackage.eAllContents.filter(EClass).findFirst[name == "Package"]
		if (o.eClass.name == "Generalization") {
			ClassificationFixes.fixNonContainmentWithSameTypes(o, root, "specific", "general", rootPackage, this)
		} else if (o.eClass.name == "ChangeEvent") {
			ChangeEventFix.fixChangeEvent(o, root, rootPackage, this)
		} else if (o.eClass.name == "FunctionBehavior") {
			FunctionBehaviorFix.fixFunctionBehavior(o, root, rootPackage, this)
		} else if (o.eClass.name == "InterfaceRealization") {	
			InterfaceRealizationFix.fixInterfaceRealization(o, root, rootPackage, this)
		} else if (o.eClass.name == "ElementImport") {
			ElementImportFix.fixElementImport(o, root, rootPackage, roots, this)
		} else if (o.eClass.name == "Association") {
			AssociationFix.fixAssociation(o, root, rootPackage, roots, this)
		} else {
			for (EReference ref : o.eClass.EAllReferences) {
				if ((ref.lowerBound == 1 && !ref.derived && ref != o.eClass.EAllReferences.findFirst[container == true])  || (o.eClass.name == "EnumerationLiteral" && ref.name == "enumeration")) {
					if (ref.name == "importedPackage") {
						PackageImportFix.fixPackageImport(o, root, rootPackage, this)
					} else if (ref.EReferenceType.abstract) {
						val tempCount1 = new HashMap<EClass, Integer>
						val tempCount2 = new HashMap<EClass, Integer>
						tempCount1.putAll(elementCounter)
						for (EClass clazz : specialElement(ref, o)) {
							if (clazz != o.eClass && !clazz.EAllSuperTypes.contains(o.eClass)) {
								elementCounter.clear
								elementCounter.putAll(tempCount1)
								val copier = abstractElement(ref, o, root, packageClass, clazz)
								
								for (EReference refer : o.eClass.EAllReferences) {
									if (refer.lowerBound == 1 && !refer.derived && !refer.container && refer.name != ref.name) {
										if (refer.EReferenceType.abstract) {
											tempCount2.putAll(elementCounter)
											for (EClass cla : specialElement(refer, o)) {
												if (cla != o.eClass && !cla.EAllSuperTypes.contains(o.eClass)) {
													elementCounter.clear
													elementCounter.putAll(tempCount2)
													abstractElement(refer, copier.getCopiedElement(o), copier.rootElement, packageClass, cla)
												}
											}
											roots.remove(copier.rootElement)
										} else {
											if (refer.name == "importedPackage") {
												PackageImportFix.fixPackageImport(o, root, rootPackage, this)
											} else {
												instantiateElement(refer, o, root, packageClass, refer.EReferenceType)
											}
										}
									}
								}
							}
						}
						roots.remove(root)
						return true
					} else {
						instantiateElement(ref, o, root, packageClass, ref.EReferenceType)
					}
				}
			}
		}
		return true
	}
	
	//Hilfsmethode zur Erstellung von Spezialisierungen abstrakter Modellelemente
	def private abstractElement(EReference ref, EObject o, EObject root, EClass packageClass, EClass clazz) {
		val copier = TraceingCopier.copy(root)
		val newRoot = copier.rootElement
		instantiateElement(ref, copier.getCopiedElement(o), newRoot, packageClass, clazz)
		roots.add(newRoot)
		return copier
	}
	//Hilfsmethode zur Erstellung von Modellelementen
	def private instantiateElement(EReference ref, EObject newObject, EObject newRoot, EClass packageClass, EClass clazz) {
		var EObject element
		if (ref.containment && ref.EReferenceType != hauptmodellelement) {
			element = createElement(clazz)
			createReferences(element, newRoot)
		} else {
			val ArrayList<EClass> path = WarshallFloyd.getPath(clazz, packageClass, graph, fWSP)
			element = createContainments(clazz, path, newRoot)
		}
		val elementName = element.eClass.getEAllAttributes.findFirst[name == "name"]
		if (elementName != null) {
			element.eSet(elementName, ref.name)
		}
		addElementToReference(newObject, ref, element)
		if (ref.EOpposite != null) {
			addElementToReference(element, ref.EOpposite, newObject)
		}
	}
	
	//Gibt Liste der Spezialisierungen von abstrakten Elementen
	def private ArrayList<EClass> specialElement(EReference ref, EObject o) {
		val allClasses = rootPackage.eAllContents.filter(EClass)
		val ArrayList<EClass> temp = findSpecialization(new ArrayList, ref.EReferenceType, allClasses)
		if (o.eClass.name == "Dependency" || o.eClass.name == "Abstraction" ||o.eClass.name == "Realization" ||o.eClass.name == "Substitution" ||o.eClass.name == "Usage" || o.eClass.name == "InterfaceRealization" || o.eClass.name == "ElementImport") {
			val ArrayList<EClass> iterList = new ArrayList
			iterList.addAll(temp)
			for (EClass clazz : iterList) {
				if (clazz.name == "Dependency" || clazz.name == "Abstraction" ||clazz.name == "Realization" ||clazz.name == "Substitution" ||clazz.name == "Usage" || clazz.name == "InterfaceRealization") {
					temp.remove(clazz)
				}
			}
		}
		return temp
	}
	
	// Instanziierung eines Modellelements und setzen des Namens
	def protected EObject createElement(EClass clazz) {
		val nameAttribute = clazz.getEAllAttributes.findFirst[name == "name"]
		val EObject classInstance = clazz.createInstance
		if (nameAttribute != null) {
			classInstance.eSet(nameAttribute, clazz.name + elementCounter.get(clazz))
		}
		return classInstance
	}
	
	// Instanziierung eines Modellelements
	def protected createInstance(EClass clazz) {
		increaseElementCounter(clazz)
		return clazz.getEPackage.getEFactoryInstance.create(clazz)
	}
	
	// Gibt den Namen des Package in dem das Modellelement liegt zurück
	def private getPackageName(EClass clazz) {
		rootPackageOmgUml.eAllContents.filter(EClass).findFirst[name == clazz.name].getEPackage.name
	}
	
	// Setzt die Referenz zwischen zwei Objekten
	def protected addElementToReference(EObject addTo, EReference ref, EObject addition) {
		if (ref.upperBound != 1) {
			(addTo.eGet(ref) as EList<EObject>).add(addition)
		} else {
			addTo.eSet(ref, addition)
		}
	}
	
	//Hilfsmethode zur benennung von erstellten Elementen
	def private increaseElementCounter(EClass clazz) {
		if (elementCounter.containsKey(clazz)) {
			elementCounter.put(clazz, elementCounter.get(clazz) + 1)
		} else {
			elementCounter.put(clazz, 1)
		}
	}
	
	def protected initializeBoundries() {
		boundry.add("UseCases")
		boundry.add("CommonStructure")
		boundry.add("CommonBehavior")
		boundry.add("Classification")
		boundry.add("SimpleClassifiers")
		//boundry.add("Values")
		//boundry.add("Actions")
		//boundry.add("Packages")
		//boundry.add("StructuredClassifiers")
		
		bannedElements.add("TemplateParameter")
		bannedElements.add("TemplateSignature")
		bannedElements.add("ClassifierTemplateParameter")
		bannedElements.add("TemplateBinding")
		bannedElements.add("TemplateParameterSubstitution")
		bannedElements.add("RedefinableTemplateSignature")
		bannedElements.add("OperationTemplateParameter")
	}
	
	// Gibt einen String mit allen Elementen die das Wurzelelement enthält aus
	def protected static String allElementsInRoot(EObject root) {
		val ArrayList<EClass> elements = new ArrayList
		val ArrayList<EObject> temp = new ArrayList
		temp.addAll(root.eContents)
		while (!temp.empty) {
			if (!elements.contains(temp.head.eClass)) {
				elements.add(temp.head.eClass)
			}
			temp.addAll(1, temp.head.eContents)
			temp.remove(temp.head)
		}
		var String contains = ""
		contains += root.eClass.name
		for (EClass c : elements) {
			contains += "_" + c.name 
		}
		return contains
	}
}