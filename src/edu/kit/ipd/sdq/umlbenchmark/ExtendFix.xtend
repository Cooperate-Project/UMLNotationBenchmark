package edu.kit.ipd.sdq.umlbenchmark

import org.eclipse.emf.ecore.EObject

class ExtendFix {
	
	
	/**
 	* Sonderbehandlung für Extend
 	* 
 	* Weist dem Modellelement ExtensionPoint das richtige Modellelement UseCase zu
 	* 
 	* @param o	Aktuelles Modellelement
 	* @param root	Wurzelelement des Diagramms
 	* @param gen	Instanz des aktuellen BenchmarkGenerators
 	*/
	def protected static fixExtend(EObject o, EObject root, BenchmarkGenerator gen) {
		var EObject useCase
		var boolean extP = false	
		for (EObject ob: root.eContents) {
			if (ob.eClass.getEAllAttributes.findFirst[name == "name"] != null && ob.eGet(ob.eClass.getEAllAttributes.findFirst[name == "name"]) == "extendedCase") {
				extP = true
			} 	
		}
		if (extP) {
			for (EObject temp: root.eContents) {
				if (temp.eClass.getEAllAttributes.findFirst[name == "name"] != null && temp.eGet(temp.eClass.getEAllAttributes.findFirst[name == "name"]) == "extendedCase") {
					useCase = temp
				} 	
			}
			gen.addElementToReference(useCase, useCase.eClass.getEAllReferences.findFirst[name == "extensionPoint"], o)
			gen.addElementToReference(o, o.eClass.getEAllReferences.findFirst[name == "useCase"], useCase)
		}
	}
}