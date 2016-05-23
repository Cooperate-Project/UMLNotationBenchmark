package edu.kit.ipd.sdq.umlbenchmark

import java.util.ArrayList
import org.eclipse.emf.ecore.EClass
import org.jgrapht.Graph
import org.jgrapht.DirectedGraph
import org.jgrapht.graph.SimpleDirectedGraph
import org.eclipse.emf.ecore.EReference
import org.jgrapht.alg.FloydWarshallShortestPaths
import org.eclipse.emf.ecore.EPackage
import java.util.HashMap
import org.jgrapht.graph.DefaultEdge

class WarshallFloyd {
	
	/**
 	* Erzeugt einen Graphen aus allen Elementen der Elementliste
 	* 
 	* Erzeugt aus der Elementliste einen Graphen, der die Containment-Beziehungen aller Modellelemente darstellt.
 	* 
 	* @param rootPackage Paket aller Elemente
 	* @param elementList	HashMap aller Modellelemente, Key Modellelemente, Value Elemente, die vom Modellelement besessen werden können
 	*/
	def protected static Graph<EClass, DefaultEdge> warshallFloyd(EPackage rootPackage, HashMap<EClass, ArrayList<EClass>> elementList) {
		val allClasses = rootPackage.eAllContents.filter(EClass)
		val ArrayList<EClass> classes = new ArrayList
		classes.addAll(allClasses.toList)
		var DefaultEdge e = new DefaultEdge
		val DirectedGraph<EClass, DefaultEdge> completeGraph = new SimpleDirectedGraph<EClass, DefaultEdge>(e.class);
		for (EClass c : classes) {
			completeGraph.addVertex(c)
			elementList.put(c, new ArrayList)
		}
		for (EClass c : classes) {
			for (EClass clazz : classes) {
				for (EReference ref: clazz.EAllContainments) {
					if(ref.EReferenceType == c && clazz != c) {
						if (!clazz.abstract) {
							var ArrayList<EClass> temp = new ArrayList
							temp.addAll(elementList.get(c))
							temp.add(clazz)
							elementList.put(c, temp)
						}
					}
				}
			}
		}
		for (EClass c : classes) {
			val ArrayList<EClass> updatedSet = new ArrayList
			updatedSet.addAll(elementList.get(c))
			if (!c.EAllSuperTypes.contains(null)) {
				for (EClass s: c.EAllSuperTypes) {
					if (s.name != null && elementList.containsKey(s)) {
						updatedSet.addAll(elementList.get(s))
						elementList.put(c, updatedSet)
					}
				}	
			}
		}
		for (EClass c : classes) {
			for (EClass clazz : elementList.get(c)) {
				if (clazz != c) {
					completeGraph.addEdge(c, clazz)
				}
			}
		}
		return completeGraph	
	}
	
	/**
 	* Ausgabe eines möglichen Pfades von Wurzelelement zu Modellelement
 	* 
 	* Gibt eine Liste zurück, die als erstes Element das Wurzelelement und
	* als letztes Element das momentan betrachtete Modellelement enthält.
	* Die Elemente dazwischen sind die jeweiligen Elternelemente.
 	* 
 	* @param start	Aktuelles Modellelement
 	* @param ziel	Wurzelelement des Diagramms
 	* @param graph	Graph der Containment-Beziehungen
 	* @param fWSP	Objekt, welches alle Informationen nach Anwendung des Floyd-Warshall-Algorithmus hält
 	*/
	def protected static ArrayList<EClass> getPath(EClass start, EClass ziel, Graph<EClass, DefaultEdge> graph, FloydWarshallShortestPaths<EClass, DefaultEdge> fWSP) {
		val gP = fWSP.getShortestPath(start, ziel)
		val ArrayList<EClass> pathAlt = new ArrayList
		for (DefaultEdge dE : gP.edgeList) {
			var EClass source = graph.getEdgeSource(dE)
			var EClass target = graph.getEdgeTarget(dE)
			if (!pathAlt.contains(source)) {
				pathAlt.add(source)
			}
			if (!pathAlt.contains(target)) {
				pathAlt.add(target)
			}
		}
		pathAlt.reverse
		return pathAlt
	}
	
}