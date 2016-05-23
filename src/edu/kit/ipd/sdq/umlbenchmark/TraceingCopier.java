package edu.kit.ipd.sdq.umlbenchmark;

import java.util.Map;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.util.EcoreUtil.Copier;

public class TraceingCopier {

    public static class TracedCopy<T extends EObject> {
        private final T rootElement;
        private final Map<EObject, EObject> trace;
        
        public TracedCopy(T rootElement, Map<EObject, EObject> trace) {
            this.rootElement = rootElement;
            this.trace = trace;
        }
        
        @SuppressWarnings("unchecked")
        public <S extends EObject> S getCopiedElement(S original) {
            return (S)trace.get(original);
        }
        
        public T getRootElement() {
            return rootElement;
        }
    }
    
    public static <T extends EObject> TracedCopy<T> copy(T eObject) {
        Copier copier = new Copier();
        EObject result = copier.copy(eObject);
        copier.copyReferences();

        @SuppressWarnings("unchecked")T t = (T)result;
        return new TracedCopy<T>(t, copier);
    }
    
}
