package edu.kit.ipd.sdq.umlbenchmark

import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EClass
import edu.kit.ipd.sdq.umlbenchmark.BenchmarkGenerator

class PackageImportFix {
	
	/**
 	* Sonderbehandlung für ImportedPackage
 	* 
 	* Die Methode erzeugt ein zweites, für ImportedPackage benötigtes Modellelement Paket.
 	* 
 	* @param o	Aktuelles Modellelement
 	* @param root	Wurzelelement des Diagramms
 	* @param rootPackage Paket aller Elemente
 	* @param gen	Instanz des aktuellen BenchmarkGenerators
 	*/
	def protected static fixPackageImport(EObject o, EObject root, EPackage rootPackage, BenchmarkGenerator gen) {
		val packageClass = rootPackage.eAllContents.filter(EClass).findFirst[name == "Package"]
		val packageInstance = gen.createElement(packageClass)
		if (packageInstance.eClass.getEAllAttributes.findFirst[name == "name"] != null) {
			packageInstance.eSet(packageInstance.eClass.EAllAttributes.findFirst[name == "name"], "Package")
		}
		gen.addElementToReference(root, packageClass.EAllReferences.findFirst[name == "packagedElement"] , packageInstance)
		gen.addElementToReference(o, o.eClass.EAllReferences.findFirst[name == "importedPackage"], packageInstance)
		gen.addElementToReference(packageInstance, packageClass.EAllReferences.findFirst[name == "nestingPackage"], root)
	}
	
}