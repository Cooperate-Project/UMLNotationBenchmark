package edu.kit.ipd.sdq.umlbenchmark

import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EPackage
import java.util.ArrayList
import org.eclipse.emf.ecore.EClass

class ClassificationFixes {
	
	/**
 	* Sonderbehandlung von Elementen wie Generalization, bei denen beide Assoziationsenden gleich sind
 	* 
 	* Die Methode erzeugt die Referenzobjekte für Elemente, bei denen die Referenzobjekte gleicher Klasse sein müssen.
 	* 
 	* @param o	Aktuelles Modellelement
 	* @param root	Wurzelelement des Diagramms
 	* @param a	Name der Referenz a
 	* @param b	Name der Referenz b
 	* @param rootPackage	Paket aller Elemente
 	* @param gen	Instanz des aktuellen BenchmarkGenerators
 	*/
	def protected static fixNonContainmentWithSameTypes(EObject o, EObject root, String a, String b, EPackage rootPackage, BenchmarkGenerator gen) {
		val packageClass = rootPackage.eAllContents.filter(EClass).findFirst[name == "Package"]
		val specificRef = o.eClass.EAllReferences.findFirst[name == a]
		val generalRef = o.eClass.EAllReferences.findFirst[name == b]
		val PackagedElementReference = packageClass.getEAllReferences.findFirst[name == "packagedElement"]
		val newObject = (o.eGet(specificRef) as EObject).eClass
		val ArrayList<EClass> path = WarshallFloyd.getPath(newObject, packageClass, gen.graph, gen.fWSP)
		val EObject element = gen.createContainments(newObject, path, root)
		gen.addElementToReference(o, generalRef, element)
		gen.addElementToReference(root, PackagedElementReference, element)
	}
	
}