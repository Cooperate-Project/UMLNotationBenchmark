package edu.kit.ipd.sdq.umlbenchmark

import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EPackage

class ChangeEventFix {
	
	/**
 	* Sonderbehandlung f�r ChangeEvent
 	* 
 	* F�gt dem ChangeEvent das ben�tigte Referenzobjekt timeExpression hinzu.
 	* 
 	* @param o	Aktuelles Modellelement
 	* @param root	Wurzelelement des Diagramms
 	* @param rootPackage Paket aller Elemente
 	* @param gen	Instanz des aktuellen BenchmarkGenerators
 	*/
	def protected static fixChangeEvent(EObject o, EObject root, EPackage rootPackage, edu.kit.ipd.sdq.umlbenchmark.BenchmarkGenerator gen) {
		val EObject timeExpression = gen.createElement(rootPackage.eAllContents.filter(EClass).findFirst[name == "TimeExpression"])
		gen.addElementToReference(o, o.eClass.getEAllReferences.findFirst[name == "changeExpression"], timeExpression)	
	}
}