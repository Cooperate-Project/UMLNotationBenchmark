package edu.kit.ipd.sdq.umlbenchmark

import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EDataType

class FunctionBehaviorFix {
	
	/**
 	* Sonderbehandlung für FunctionBehavior
 	* 
 	* FunctionBehavior benötigt durch ein Contraint einen OutputParameter. 
 	* Dieser wird hier erzeugt und als Referenz gesetzt.
 	* 
 	* @param o	Aktuelles Modellelement
 	* @param root	Wurzelelement des Diagramms
 	* @param rootPackage Paket aller Elemente
 	* @param gen	Instanz des aktuellen BenchmarkGenerators
 	*/
	def protected static fixFunctionBehavior(EObject o, EObject root, EPackage rootPackage, edu.kit.ipd.sdq.umlbenchmark.BenchmarkGenerator gen) {
		val EObject outputParameter = gen.createElement(rootPackage.eAllContents.filter(EClass).findFirst[name == "Parameter"])
		val directionRef = outputParameter.eClass.getEAllAttributes.findFirst[name == "direction"]
		outputParameter.eSet(directionRef, directionRef.getEType.getEPackage.getEFactoryInstance.createFromString(directionRef.getEType as EDataType, "out"))
		gen.addElementToReference(o, o.eClass.getEAllReferences.findFirst[name == "ownedParameter"], outputParameter)
	}
}
	