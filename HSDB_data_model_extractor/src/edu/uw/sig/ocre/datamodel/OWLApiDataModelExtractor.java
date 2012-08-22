/**
 * 
 */
package edu.uw.sig.ocre.datamodel;

import java.util.Collections;
import java.util.HashSet;
import java.util.Set;

import org.semanticweb.owlapi.apibinding.OWLManager;
import org.semanticweb.owlapi.model.IRI;
import org.semanticweb.owlapi.model.OWLClass;
import org.semanticweb.owlapi.model.OWLClassExpression;
import org.semanticweb.owlapi.model.OWLEquivalentClassesAxiom;
import org.semanticweb.owlapi.model.OWLObjectAllValuesFrom;
import org.semanticweb.owlapi.model.OWLObjectPropertyExpression;
import org.semanticweb.owlapi.model.OWLObjectSomeValuesFrom;
import org.semanticweb.owlapi.model.OWLOntology;
import org.semanticweb.owlapi.model.OWLOntologyCreationException;
import org.semanticweb.owlapi.model.OWLOntologyManager;
import org.semanticweb.owlapi.model.OWLProperty;
import org.semanticweb.owlapi.model.OWLSubClassOfAxiom;
import org.semanticweb.owlapi.util.OWLClassExpressionVisitorAdapter;

/**
 * @author detwiler
 * @date Mar 21, 2011
 */
public class OWLApiDataModelExtractor
{
	public static final String DOCUMENT_IRI = "http://purl.org/sig/OCRe";
	
	private void getAllValuesFrom(OWLClass subclass, OWLProperty property)
	{
		
		//subclass.getAllValuesFrom(property);
	}
	

	/**
	 * @param args
	 */
	public static void main(String[] args)
	{
		try {
            // Create our manager
            OWLOntologyManager man = OWLManager.createOWLOntologyManager();

            // Load the OCRe ontology
            OWLOntology ont = man.loadOntologyFromOntologyDocument(IRI.create(DOCUMENT_IRI));
            System.out.println("Loaded: " + ont.getOntologyID());

            IRI studyIRI = IRI.create("http://purl.org/net/OCRe/OCRe_ext.owl#OCRE571000");
            OWLClass study = man.getOWLDataFactory().getOWLClass(studyIRI);

            // Now we want to collect the properties which are used in existential restrictions on the
            // class.  To do this, we will create a utility class - RestrictionVisitor, which acts as
            // a filter for existential restrictions.  This uses the Visitor Pattern (google Visitor Design
            // Pattern for more information on this design pattern, or see http://en.wikipedia.org/wiki/Visitor_pattern)
            RestrictionVisitor restrictionVisitor = new RestrictionVisitor(Collections.singleton(ont));
            // In this case, restrictions are used as (anonymous) superclasses, so to get the restrictions on
            // margherita pizza we need to obtain the subclass axioms for margherita pizza.
            for (OWLSubClassOfAxiom ax : ont.getSubClassAxiomsForSubClass(study)) {
                OWLClassExpression superCls = ax.getSuperClass();
                // Ask our superclass to accept a visit from the RestrictionVisitor - if it is an
                // existential restiction then our restriction visitor will answer it - if not our
                // visitor will ignore it
                superCls.accept(restrictionVisitor);
            }
            // Our RestrictionVisitor has now collected all of the properties that have been restricted in existential
            // restrictions - print them out.
            System.out.println("Existential restricted properties for " + study + ": " + restrictionVisitor.getExistRestrictedProperties().size());
            for (OWLObjectPropertyExpression prop : restrictionVisitor.getExistRestrictedProperties()) {
                System.out.println("    " + prop);
            }
            
            System.out.println("Universal restricted properties for " + study + ": " + restrictionVisitor.getUnivRestrictedProperties().size());
            for (OWLObjectPropertyExpression prop : restrictionVisitor.getUnivRestrictedProperties()) {
                System.out.println("    " + prop);
            }

        }
        catch (OWLOntologyCreationException e) {
            System.out.println("Could not load ontology: " + e.getMessage());
        }

	}
	
	/**
	 * Visits existential restrictions and collects the properties which are restricted
	 */
	private static class RestrictionVisitor extends OWLClassExpressionVisitorAdapter {

	    private boolean processInherited = true;

	    private Set<OWLClass> processedClasses;

	    private Set<OWLObjectPropertyExpression> existRestrictedProperties;
	    private Set<OWLObjectPropertyExpression> univRestrictedProperties;

	    private Set<OWLOntology> onts;

	    public RestrictionVisitor(Set<OWLOntology> onts) {
	        existRestrictedProperties = new HashSet<OWLObjectPropertyExpression>();
	        univRestrictedProperties = new HashSet<OWLObjectPropertyExpression>();
	        processedClasses = new HashSet<OWLClass>();
	        this.onts = onts;
	    }


	    public void setProcessInherited(boolean processInherited) {
	        this.processInherited = processInherited;
	    }


	    public Set<OWLObjectPropertyExpression> getExistRestrictedProperties() {
	        return existRestrictedProperties;
	    }

	    
	    public Set<OWLObjectPropertyExpression> getUnivRestrictedProperties() {
	        return univRestrictedProperties;
	    }

	    
	    public void visit(OWLClass desc) {
	        if (processInherited && !processedClasses.contains(desc)) {
	            // If we are processing inherited restrictions then
	            // we recursively visit named supers.  Note that we
	            // need to keep track of the classes that we have processed
	            // so that we don't get caught out by cycles in the taxonomy
	            processedClasses.add(desc);
	            for (OWLOntology ont : onts) {
	                for (OWLSubClassOfAxiom subAx : ont.getSubClassAxiomsForSubClass(desc)) {
	                	subAx.getSuperClass().accept(this);
	                }	
	                for (OWLEquivalentClassesAxiom equivAx : ont.getEquivalentClassesAxioms(desc))
	                {
	                	for (OWLSubClassOfAxiom subAx : equivAx.asOWLSubClassOfAxioms())
	                	{
	                		subAx.getSuperClass().accept(this);
	                	}
	                }
	            }
	        }
	    }


	    public void reset() {
	        processedClasses.clear();
	        existRestrictedProperties.clear();
	        univRestrictedProperties.clear();
	    }


	    public void visit(OWLObjectSomeValuesFrom desc) {
	        // This method gets called when a class expression is an
	        // existential (someValuesFrom) restriction and it asks us to visit it
	        existRestrictedProperties.add(desc.getProperty());
	    }
	    
	    public void visit(OWLObjectAllValuesFrom desc) {
	    	univRestrictedProperties.add(desc.getProperty());
	    }
	    
	}

}
