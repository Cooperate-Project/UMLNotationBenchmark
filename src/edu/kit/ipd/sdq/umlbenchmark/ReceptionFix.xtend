package edu.kit.ipd.sdq.umlbenchmark

import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EClass

class ReceptionFix {
	
	/**
 	* Sonderbehandlung für Reception
 	* 
 	* Fügt Reception dem benötigten Modellelement Interface hinzu.
 	* 
 	* @param o	Aktuelles Modellelement
 	* @param root	Wurzelelement des Diagramms
 	* @param rootPackage Paket aller Elemente
 	* @param gen	Instanz des aktuellen BenchmarkGenerators
 	*/
	def protected static fixReception(EObject o, EObject root, EPackage rootPackage, BenchmarkGenerator gen) {
		val EObject interface = gen.createElement(rootPackage.eAllContents.filter(EClass).findFirst[name == "Interface"])
		val ownedReceptionRef = interface.eClass.EAllReferences.findFirst[name == "ownedReception"]
		gen.addElementToReference(interface, ownedReceptionRef, o)
		gen.addElementToReference(root, root.eClass.EAllReferences.findFirst[name == "packagedElement"], interface)
	}
	
}