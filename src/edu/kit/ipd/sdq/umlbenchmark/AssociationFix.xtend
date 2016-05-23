package edu.kit.ipd.sdq.umlbenchmark

import org.eclipse.emf.ecore.EObject
import java.util.HashSet
import org.eclipse.emf.ecore.EPackage
import java.util.ArrayList
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.util.EcoreUtil

class AssociationFix {
	
	/**
 	* Sonderbehandlung für Association
 	* 
 	* Schnelle Implementation des Modellelements Association für UseCase-Diagramme.
 	* Erzeugt nur binäre Assoziationen.
 	* 
 	* @param o	Aktuelles Modellelement
 	* @param root	Wurzelelement des Diagramms
 	* @param rootPackage Paket aller Elemente
 	* @param roots	Liste aller Wurzelelemente 
 	* @param gen	Instanz des aktuellen BenchmarkGenerators
 	*/
	def protected static fixAssociation(EObject o, EObject root, EPackage rootPackage, HashSet<EObject> roots, BenchmarkGenerator gen) {
		val ArrayList<EClass> specTemp = gen.findSpecialization(new ArrayList, rootPackage.eAllContents.filter(EClass).findFirst[name == "Classifier"], rootPackage.eAllContents.filter(EClass))
		val ArrayList<EClass> done = new ArrayList
		for (EClass s : specTemp) {
			for (EClass p : specTemp) {
				if (!done.contains(p)) {
					if ((s.name == "Actor" && p.name == "UseCase") ||  (p.name == "Actor" && s.name == "UseCase") || (s.name != "Actor" && p.name != "Actor")) {
						val copier = TraceingCopier.copy(root)
						val newRoot = copier.rootElement
						roots.add(newRoot)
						val EObject newObject = copier.getCopiedElement(o)
						
						val EObject classifier1 = gen.createInstance(s)
						val EObject classifier2 = gen.createInstance(p)
						classifier1.eSet(classifier1.eClass.EAllAttributes.findFirst[name == "name"], classifier1.eClass.name + "1")
						classifier2.eSet(classifier2.eClass.EAllAttributes.findFirst[name == "name"], classifier2.eClass.name + "2")
						val EObject property1 = gen.createInstance(rootPackage.eAllContents.filter(EClass).findFirst[name == "Property"])
						val EObject property2 = gen.createInstance(rootPackage.eAllContents.filter(EClass).findFirst[name == "Property"])		
						property1.eSet(property1.eClass.EAllAttributes.findFirst[name == "name"], "Property1")
						property2.eSet(property2.eClass.EAllAttributes.findFirst[name == "name"], "Property2")
						gen.addElementToReference(newObject, newObject.eClass.EAllReferences.findFirst[name == "memberEnd"], property1)
						gen.addElementToReference(newObject, newObject.eClass.EAllReferences.findFirst[name == "memberEnd"], property2)
						gen.addElementToReference(property1, property1.eClass.EAllReferences.findFirst[name == "association"], newObject)
						gen.addElementToReference(property2, property2.eClass.EAllReferences.findFirst[name == "association"], newObject)
						gen.addElementToReference(property1, property1.eClass.EAllReferences.findFirst[name == "owningAssociation"], newObject)
						gen.addElementToReference(property2, property2.eClass.EAllReferences.findFirst[name == "owningAssociation"], newObject)
						gen.addElementToReference(property1, property1.eClass.EAllReferences.findFirst[name == "type"], classifier1)
						gen.addElementToReference(property2, property2.eClass.EAllReferences.findFirst[name == "type"], classifier2)
						gen.addElementToReference(newRoot, newRoot.eClass.EAllReferences.findFirst[name == "packagedElement"], classifier1)
						gen.addElementToReference(newRoot, newRoot.eClass.EAllReferences.findFirst[name == "packagedElement"], classifier2)
					}
				}
			}
			done.add(s)
		}
		roots.remove(root)
	}
	
}