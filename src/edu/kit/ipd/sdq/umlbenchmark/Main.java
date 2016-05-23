package edu.kit.ipd.sdq.umlbenchmark;

import java.io.File;
import java.io.IOException;
import java.util.Collections;
import java.util.Map;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.EPackage.Registry;
import org.eclipse.emf.ecore.EcorePackage;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.emf.ecore.xmi.impl.EcoreResourceFactoryImpl;
import org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl;
import org.eclipse.uml2.uml.UMLPackage;
import org.eclipse.uml2.uml.resource.UMLResource;

public class Main {

    private static ResourceSet createResourceSet() {
        final ResourceSet rs = new ResourceSetImpl();
        
        URI oldEcoreURI = URI.createURI("platform:/plugin/org.eclipse.emf.ecore/model/Ecore.ecore");
        URI newEcoreURI = URI.createFileURI("metamodels/Ecore.ecore");
        
        rs.getURIConverter().getURIMap().put(oldEcoreURI, newEcoreURI);
        
        return rs;
    }
    
	static {
		Resource.Factory.Registry reg = Resource.Factory.Registry.INSTANCE;
	    Map<String, Object> m = reg.getExtensionToFactoryMap();
	    m.put(Resource.Factory.Registry.DEFAULT_EXTENSION, new XMIResourceFactoryImpl());
	    m.put(UMLResource.FILE_EXTENSION, UMLResource.Factory.INSTANCE);
	    m.put("ecore", new EcoreResourceFactoryImpl());

	    Registry packageRegistry = EPackage.Registry.INSTANCE;
	    //packageRegistry.replace(TypesPackage.eNS_URI, TypesPackage.eINSTANCE);
	    packageRegistry.replace(UMLPackage.eNS_URI, UMLPackage.eINSTANCE);
	    packageRegistry.replace(EcorePackage.eNS_URI, EcorePackage.eINSTANCE);
	}
	
	public static void main(String[] args) throws IOException {	
		BenchmarkGenerator generator = new BenchmarkGenerator(loadEclipseUMLRootPackage(), loadOMGUMLRootPackage());
		saveModels(generator.createBenchmarks());
	}
	
	private static EPackage loadEclipseUMLRootPackage() throws IOException {
		return loadEcoreModel("metamodels/UML.ecore");
	}
	
	private static EPackage loadOMGUMLRootPackage() throws IOException {
		return loadEcoreModel("metamodels/UML_Packaged.ecore");
	}
	
	private static EPackage loadEcoreModel(String projectRelativePath) throws IOException {
		ResourceSet rs = createResourceSet();
		File p = new File(projectRelativePath);
		URI uri = URI.createFileURI(p.getAbsolutePath());
		Resource r = rs.createResource(uri);
		r.load(null);
		EcoreUtil.resolveAll(r);
		return (EPackage) r.getContents().get(0);
	}
	
	private static void saveModels(Iterable<EObject> models) throws IOException {
		ResourceSet rs = createResourceSet();
		for (EObject rootElement : models) {
			Resource r = rs.createResource(URI.createFileURI("models/benchmarks/" + BenchmarkGenerator.allElementsInRoot(rootElement) + ".uml"));
			r.getContents().add(rootElement);
			r.save(Collections.EMPTY_MAP);
		}
	}

}
