package edu.kit.ipd.sdq.umlbenchmark

import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EClass
import java.util.ArrayList
import org.eclipse.emf.ecore.util.EcoreUtil
import java.util.HashSet
import edu.kit.ipd.sdq.umlbenchmark.BenchmarkGenerator

class ElementImportFix {
	
	/**
 	* Sonderbehandlung für ElementImport
 	* 
 	* Bei ElementImport gibt es Probleme mit der Referennz auf die jeweiligen Referenzelemente.
 	* Der Name der Referenz ist je nach Modellelement unterschiedlich.
 	* Die Methode setzt manuell die jeweils richtige Referenz.
 	* 
 	* @param o	Aktuelles Modellelement
 	* @param root	Wurzelelement des Diagramms
 	* @param rootPackage Paket aller Elemente
 	* @param roots Liste aller Wurzelelemente
 	* @param gen	Instanz des aktuellen BenchmarkGenerators
 	*/
	def protected  static fixElementImport(EObject o, EObject root, EPackage rootPackage, HashSet<EObject> roots, BenchmarkGenerator gen) {
		val ArrayList<EClass> specTemp = gen.findSpecialization(new ArrayList, rootPackage.eAllContents.filter(EClass).findFirst[name == "Namespace"], rootPackage.eAllContents.filter(EClass))
		val ArrayList<EClass> packTemp = gen.findSpecialization(new ArrayList, rootPackage.eAllContents.filter(EClass).findFirst[name == "PackageableElement"], rootPackage.eAllContents.filter(EClass))
		for (EClass s : specTemp) {
			if (s != o.eContainer.eClass) {
				for (EClass p : packTemp) {
					val EObject newRoot = EcoreUtil.copy(root)
					roots.add(newRoot)
					var EObject newObject
					if (newRoot.eContents.head.eContents.head.eClass.name == o.eClass.name) {
						newObject = newRoot.eContents.head.eContents.head
					} else if (newRoot.eContents.head.eContents.head.eContents.head.eClass.name == o.eClass.name) {
						newObject = newRoot.eContents.head.eContents.head.eContents.head
					}
					val EObject namespace = gen.createElement(s)
					val EObject packageableElement = gen.createElement(p)
					gen.addElementToReference(newObject, newObject.eClass.getEAllReferences.findFirst[name == "importedElement"], packageableElement)
					if (namespace.eClass.name == "Interface") {
						if (namespace.eClass.getEAllReferences.findFirst[name == "nestedClassifier"].EReferenceType == packageableElement.eClass || packageableElement.eClass.ESuperTypes.contains(namespace.eClass.getEAllReferences.findFirst[name == "nestedClassifier"].EReferenceType)) {						
							gen.addElementToReference(namespace, namespace.eClass.getEAllReferences.findFirst[name == "nestedClassifier"], packageableElement)
						} else if (namespace.eClass.getEAllReferences.findFirst[name == "ownedAttribute"].EReferenceType == packageableElement.eClass || packageableElement.eClass.ESuperTypes.contains(namespace.eClass.getEAllReferences.findFirst[name == "ownedAttribute"].EReferenceType)) {						
							gen.addElementToReference(namespace, namespace.eClass.getEAllReferences.findFirst[name == "ownedAttribute"], packageableElement)
						} else if (namespace.eClass.getEAllReferences.findFirst[name == "ownedOperation"].EReferenceType == packageableElement.eClass || packageableElement.eClass.ESuperTypes.contains(namespace.eClass.getEAllReferences.findFirst[name == "ownedOperation"].EReferenceType)) {						
							gen.addElementToReference(namespace, namespace.eClass.getEAllReferences.findFirst[name == "ownedOperation"], packageableElement)
						} else if (namespace.eClass.getEAllReferences.findFirst[name == "ownedReception"].EReferenceType == packageableElement.eClass || packageableElement.eClass.ESuperTypes.contains(namespace.eClass.getEAllReferences.findFirst[name == "ownedReception"].EReferenceType)) {						
							gen.addElementToReference(namespace, namespace.eClass.getEAllReferences.findFirst[name == "ownedReception"], packageableElement)
						} else if (namespace.eClass.getEAllReferences.findFirst[name == "protocol"].EReferenceType == packageableElement.eClass || packageableElement.eClass.ESuperTypes.contains(namespace.eClass.getEAllReferences.findFirst[name == "protocol"].EReferenceType)) {						
							gen.addElementToReference(namespace, namespace.eClass.getEAllReferences.findFirst[name == "protocol"], packageableElement)
						} else {
							roots.remove(newRoot)
						}
					} else if (namespace.eClass.name == "Signal") {
						if (namespace.eClass.getEAllReferences.findFirst[name == "ownedAttribute"].EReferenceType == packageableElement.eClass || packageableElement.eClass.ESuperTypes.contains(namespace.eClass.getEAllReferences.findFirst[name == "ownedAttribute"].EReferenceType)) {						
							gen.addElementToReference(namespace, namespace.eClass.getEAllReferences.findFirst[name == "ownedAttribute"], packageableElement)
						} else {
							roots.remove(newRoot)
						}
					} else if (namespace.eClass.name == "DataType") {
						if (namespace.eClass.getEAllReferences.findFirst[name == "ownedAttribute"].EReferenceType == packageableElement.eClass || packageableElement.eClass.ESuperTypes.contains(namespace.eClass.getEAllReferences.findFirst[name == "ownedAttribute"].EReferenceType)) {						
							gen.addElementToReference(namespace, namespace.eClass.getEAllReferences.findFirst[name == "ownedAttribute"], packageableElement)
						} else if (namespace.eClass.getEAllReferences.findFirst[name == "ownedOperation"].EReferenceType == packageableElement.eClass || packageableElement.eClass.ESuperTypes.contains(namespace.eClass.getEAllReferences.findFirst[name == "ownedOperation"].EReferenceType)) {						
							gen.addElementToReference(namespace, namespace.eClass.getEAllReferences.findFirst[name == "ownedOperation"], packageableElement)
						} else {
							roots.remove(newRoot)
						}
					} else if (namespace.eClass.name == "PrimitiveType") {
						if (namespace.eClass.getEAllReferences.findFirst[name == "ownedAttribute"].EReferenceType == packageableElement.eClass || packageableElement.eClass.ESuperTypes.contains(namespace.eClass.getEAllReferences.findFirst[name == "ownedAttribute"].EReferenceType)) {						
							gen.addElementToReference(namespace, namespace.eClass.getEAllReferences.findFirst[name == "ownedAttribute"], packageableElement)
						} else if (namespace.eClass.getEAllReferences.findFirst[name == "ownedOperation"].EReferenceType == packageableElement.eClass || packageableElement.eClass.ESuperTypes.contains(namespace.eClass.getEAllReferences.findFirst[name == "ownedOperation"].EReferenceType)) {						
							gen.addElementToReference(namespace, namespace.eClass.getEAllReferences.findFirst[name == "ownedOperation"], packageableElement)
						} else {
							roots.remove(newRoot)
						}					
					} else if (namespace.eClass.name == "Actor") {
						if (namespace.eClass.getEAllReferences.findFirst[name == "ownedBehavior"].EReferenceType == packageableElement.eClass || packageableElement.eClass.ESuperTypes.contains(namespace.eClass.getEAllReferences.findFirst[name == "ownedBehavior"].EReferenceType)) {						
							gen.addElementToReference(namespace, namespace.eClass.getEAllReferences.findFirst[name == "ownedBehavior"], packageableElement)
						} else {
							roots.remove(newRoot)
						}
					} else if (namespace.eClass.name == "UseCase") {
						if (namespace.eClass.getEAllReferences.findFirst[name == "ownedBehavior"].EReferenceType == packageableElement.eClass || packageableElement.eClass.ESuperTypes.contains(namespace.eClass.getEAllReferences.findFirst[name == "ownedBehavior"].EReferenceType)) {						
							gen.addElementToReference(namespace, namespace.eClass.getEAllReferences.findFirst[name == "ownedBehavior"], packageableElement)
						} else {
							roots.remove(newRoot)
						}					
					} else if (namespace.eClass.name == "OpaqueBehavior") {
						if (namespace.eClass.getEAllReferences.findFirst[name == "ownedParameter"].EReferenceType == packageableElement.eClass || packageableElement.eClass.ESuperTypes.contains(namespace.eClass.getEAllReferences.findFirst[name == "ownedParameter"].EReferenceType)) {						
							gen.addElementToReference(namespace, namespace.eClass.getEAllReferences.findFirst[name == "ownedParameter"], packageableElement)
						} else if (namespace.eClass.getEAllReferences.findFirst[name == "ownedParameterSet"].EReferenceType == packageableElement.eClass || packageableElement.eClass.ESuperTypes.contains(namespace.eClass.getEAllReferences.findFirst[name == "ownedParameterSet"].EReferenceType)) {						
							gen.addElementToReference(namespace, namespace.eClass.getEAllReferences.findFirst[name == "ownedParameterSet"], packageableElement)
						} else {
							roots.remove(newRoot)
						}					
					} else if (namespace.eClass.name == "FunctionBehavior") {
						if (namespace.eClass.getEAllReferences.findFirst[name == "ownedParameter"].EReferenceType == packageableElement.eClass || packageableElement.eClass.ESuperTypes.contains(namespace.eClass.getEAllReferences.findFirst[name == "ownedParameter"].EReferenceType)) {						
							gen.addElementToReference(namespace, namespace.eClass.getEAllReferences.findFirst[name == "ownedParameter"], packageableElement)
						} else if (namespace.eClass.getEAllReferences.findFirst[name == "ownedParameterSet"].EReferenceType == packageableElement.eClass || packageableElement.eClass.ESuperTypes.contains(namespace.eClass.getEAllReferences.findFirst[name == "ownedParameterSet"].EReferenceType)) {						
							gen.addElementToReference(namespace, namespace.eClass.getEAllReferences.findFirst[name == "ownedParameterSet"], packageableElement)
						} else {
							roots.remove(newRoot)
						}
					} else if (namespace.eClass.name == "Reception") {
						if (namespace.eClass.getEAllReferences.findFirst[name == "ownedParameter"].EReferenceType == packageableElement.eClass || packageableElement.eClass.ESuperTypes.contains(namespace.eClass.getEAllReferences.findFirst[name == "ownedParameter"].EReferenceType)) {						
							gen.addElementToReference(namespace, namespace.eClass.getEAllReferences.findFirst[name == "ownedParameter"], packageableElement)
						} else if (namespace.eClass.getEAllReferences.findFirst[name == "ownedParameterSet"].EReferenceType == packageableElement.eClass || packageableElement.eClass.ESuperTypes.contains(namespace.eClass.getEAllReferences.findFirst[name == "ownedParameterSet"].EReferenceType)) {						
							gen.addElementToReference(namespace, namespace.eClass.getEAllReferences.findFirst[name == "ownedParameterSet"], packageableElement)
						} else {
							roots.remove(newRoot)
						}					
					} else if (namespace.eClass.name == "Operation") {
						if (namespace.eClass.getEAllReferences.findFirst[name == "ownedParameter"].EReferenceType == packageableElement.eClass || packageableElement.eClass.ESuperTypes.contains(namespace.eClass.getEAllReferences.findFirst[name == "ownedParameter"].EReferenceType)) {						
							gen.addElementToReference(namespace, namespace.eClass.getEAllReferences.findFirst[name == "ownedParameter"], packageableElement)
						} else if (namespace.eClass.getEAllReferences.findFirst[name == "ownedParameterSet"].EReferenceType == packageableElement.eClass || packageableElement.eClass.ESuperTypes.contains(namespace.eClass.getEAllReferences.findFirst[name == "ownedParameterSet"].EReferenceType)) {						
							gen.addElementToReference(namespace, namespace.eClass.getEAllReferences.findFirst[name == "ownedParameterSet"], packageableElement)
						} else {
							roots.remove(newRoot)
						}					
					} else if (namespace.eClass.name == "Enumeration") {
						if (namespace.eClass.getEAllReferences.findFirst[name == "ownedAttribute"].EReferenceType == packageableElement.eClass || packageableElement.eClass.ESuperTypes.contains(namespace.eClass.getEAllReferences.findFirst[name == "ownedAttribute"].EReferenceType)) {						
							gen.addElementToReference(namespace, namespace.eClass.getEAllReferences.findFirst[name == "ownedAttribute"], packageableElement)
						} else if (namespace.eClass.getEAllReferences.findFirst[name == "ownedLiteral"].EReferenceType == packageableElement.eClass || packageableElement.eClass.ESuperTypes.contains(namespace.eClass.getEAllReferences.findFirst[name == "ownedLiteral"].EReferenceType)) {						
							gen.addElementToReference(namespace, namespace.eClass.getEAllReferences.findFirst[name == "ownedLiteral"], packageableElement)
						} else {
							roots.remove(newRoot)
						}					
					}
					gen.addElementToReference(newRoot, newRoot.eClass.getEAllReferences.findFirst[name == "packagedElement"], namespace)
				}
			}
		}
		roots.remove(root)
	}
}