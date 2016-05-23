package edu.kit.ipd.sdq.umlbenchmark

import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EPackage

class TriggerFix {
	
	/**
 	* Sonderbehandlung für Trigger
 	* 
 	* Für Trigger funktioniert das Finden einen Pfades zum Wurzelelement nicht korrekt.
 	* Die Methode setzt einen möglichen Pfad, damit die Erzeugung des Elements funktioniert.
 	* 
 	* @param o	Aktuelles Modellelement
 	* @param root	Wurzelelement des Diagramms
 	* @param rootPackage Paket aller Elemente
 	* @param gen	Instanz des aktuellen BenchmarkGenerators
 	*/
	def protected static fixTrigger(EObject o, EObject root, EPackage rootPackage, edu.kit.ipd.sdq.umlbenchmark.BenchmarkGenerator gen) {
		val EObject interaction = gen.createElement(rootPackage.eAllContents.filter(EClass).findFirst[name == "Interaction"])
		val EObject acceptEventAction = gen.createElement(rootPackage.eAllContents.filter(EClass).findFirst[name == "AcceptEventAction"])
		val packageClass = rootPackage.eAllContents.filter(EClass).findFirst[name == "Package"]
		val PackagedElementReference = packageClass.getEAllReferences.findFirst[name == "packagedElement"]
		gen.addElementToReference(root, PackagedElementReference, interaction)
		gen.addElementToReference(interaction, interaction.eClass.getEAllReferences.findFirst[name == "action"], acceptEventAction)
		gen.addElementToReference(acceptEventAction, acceptEventAction.eClass.getEAllReferences.findFirst[name == "trigger"], o)
	}
	
}
	