package edu.kit.ipd.sdq.umlbenchmark

import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EClass

class InterfaceRealizationFix {
	
	/**
 	* Sonderbehandlung für InterfaceRealization
 	* 
 	* Setzt benötigte Refrenzen contract und supplier manuell.
 	* 
 	* @param o	Aktuelles Modellelement
 	* @param root	Wurzelelement des Diagramms
 	* @param rootPackage Paket aller Elemente
 	* @param gen	Instanz des aktuellen BenchmarkGenerators
 	*/
	def protected static fixInterfaceRealization(EObject o, EObject root, EPackage rootPackage, BenchmarkGenerator gen) {
		val package = rootPackage.eAllContents.filter(EClass).findFirst[name == "Package"]
		val contractRef = o.eClass.EAllReferences.findFirst[name == "contract"]
		val EObject interface = gen.createElement(rootPackage.eAllContents.filter(EClass).findFirst[name == "Interface"])
		gen.addElementToReference(o, contractRef, interface)
		gen.addElementToReference(o, o.eClass.EAllReferences.findFirst[name == "supplier"], interface)
		gen.addElementToReference(root, package.EAllReferences.findFirst[name == "packagedElement"], interface)
	}
}