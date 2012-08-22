/**
 * 
 */
package edu.uw.sig.ocre.datamodel.util;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import org.semanticweb.owlapi.model.IRI;
import org.semanticweb.owlapi.model.OWLAnnotation;
import org.semanticweb.owlapi.model.OWLAnnotationAssertionAxiom;
import org.semanticweb.owlapi.model.OWLClass;
import org.semanticweb.owlapi.model.OWLClassExpression;
import org.semanticweb.owlapi.model.OWLDataFactory;
import org.semanticweb.owlapi.model.OWLIndividual;
import org.semanticweb.owlapi.model.OWLLiteral;
import org.semanticweb.owlapi.model.OWLOntology;

import edu.uw.sig.ocre.datamodel.SimpleType;
import edu.uw.sig.ocre.datamodel.StringEnumerationType;

/**
 * @author detwiler
 * @date Sep 15, 2011
 */
public class ValueSetGenerator
{
	private OWLOntology ont;
	private OWLDataFactory df;
	
	private enum SubclassType {LEAVES, ALL_INC_ROOT, ALL_EXC_ROOT}
	
	public ValueSetGenerator(OWLOntology ont, OWLDataFactory df)
	{
		this.ont = ont;
		this.df = df;
	}
	
	public SimpleType individualValueSet(OWLClass rootClass, String typeName)
	{
		// create string enumeration type
		StringEnumerationType enumType = new StringEnumerationType(
				typeName, rootClass.getIRI().toString());
		Set<OWLIndividual> individuals = rootClass.getIndividuals(ont);
		
		// create string enumeration from individuals' names
		Map<String,IRI> enumElements = new HashMap<String,IRI>();
		for(OWLIndividual individual : individuals)
		{
			Set<OWLAnnotationAssertionAxiom> annots;
			if(individual.isAnonymous())
			{
				annots = ont.getAnnotationAssertionAxioms(individual.asOWLAnonymousIndividual());
			}
			else
			{
				annots = ont.getAnnotationAssertionAxioms(individual.asOWLNamedIndividual().getIRI());
			}
			
			// for now we presume only one label and no internationalization (i.e. English labels only)
			// grab first label annotation
			String label = null;
			for(OWLAnnotationAssertionAxiom annot : annots)
			{
				if(annot.getProperty().equals(df.getRDFSLabel()))
				{
					label = ((OWLLiteral)annot.getValue()).getLiteral();
					break;
				}
			}
			if(label==null)
				continue;
					
			IRI indIRI = individual.asOWLNamedIndividual().getIRI();
			
			enumElements.put(label, indIRI);
		}
		enumType.setEnumElements(enumElements);
		
		return enumType;
	}
	
	public SimpleType LeafSubclassValueSet(OWLClass rootClass, String typeName)
	{
		Set<OWLClass> subclasses = buildSubclassValueSetKicker(rootClass,SubclassType.LEAVES);
		SimpleType valueSet = enumTypeFromClassSet(rootClass,subclasses,typeName);
		return valueSet;
		/*
		// create string enumeration type
		StringEnumerationType enumType = new StringEnumerationType(
				typeName, rootClass.getIRI().toString());
		Set<OWLClassExpression> subclasses = rootClass.getSubClasses(ont);
		
		// determine leaves (have only children equivalent to the bottom class)
		Set<OWLClass> leaves = new HashSet<OWLClass>();
		for(OWLClassExpression subclass : subclasses)
		{
			// note presently we assume value sets are lists of named classes, no set combinations i.e. unions or intersections
			// TODO: deal with more complex class expressions in value sets
			if(subclass instanceof OWLClass)
			{
				Set<OWLClassExpression> subsubs = subclass.asOWLClass().getSubClasses(ont);
				boolean isleaf = true;
				for(OWLClassExpression subsub : subsubs)
				{
					if(!(subsub.isBottomEntity()||subsub.isOWLNothing()))
							isleaf=false;
				}
				if(isleaf)
					leaves.add(subclass.asOWLClass());
			}
		}
		
		// create string enumeration from subclasses' names
		Map<String,IRI> enumElements = new HashMap<String,IRI>();
		for(OWLClass leaf : leaves)
		{
			Set<OWLAnnotation> leafLabels = leaf.getAnnotations(ont, df.getRDFSLabel());
			
			// for now we presume only one label and no internationalization (i.e. English labels only)
			if(leafLabels.size()==0)
				continue;
			
			String label = ((OWLLiteral)leafLabels.iterator().next().getValue()).getLiteral();	
			IRI leafIRI = leaf.getIRI();
			
			enumElements.put(label, leafIRI);
		}
		enumType.setEnumElements(enumElements);
		
		return enumType;
		*/
	}
	
	public SimpleType subclassValueSetIncRoot(OWLClass rootClass, String typeName)
	{
		Set<OWLClass> subclasses = buildSubclassValueSetKicker(rootClass,SubclassType.ALL_INC_ROOT);
		SimpleType valueSet = enumTypeFromClassSet(rootClass,subclasses,typeName);
		return valueSet;
		/*
		// create string enumeration type
		StringEnumerationType enumType = new StringEnumerationType(
				typeName, rootClass.getIRI().toString());
		Set<OWLClassExpression> subclasses = rootClass.getSubClasses(ont);
		
		// create string enumeration from subclasses' names
		Map<String,IRI> enumElements = new HashMap<String,IRI>();
		for(OWLClassExpression subclass : subclasses)
		{
			// note presently we assume value sets are lists of named classes, no set combinations i.e. unions or intersections
			// TODO: deal with more complex class expressions in value sets
			if(!(subclass instanceof OWLClass))
			{
				continue;
			}
			
			
			Set<OWLAnnotation> subclassLabels = subclass.asOWLClass().getAnnotations(ont, df.getRDFSLabel());
			
			// for now we presume only one label and no internationalization (i.e. English labels only)
			if(subclassLabels.size()==0)
				continue;
			
			String label = ((OWLLiteral)subclassLabels.iterator().next().getValue()).getLiteral();		
			IRI subclassIRI = subclass.asOWLClass().getIRI();
			
			enumElements.put(label, subclassIRI);
		}
		enumType.setEnumElements(enumElements);
		
		return enumType;
		*/
	}
	
	public SimpleType subclassValueSetExcRoot(OWLClass rootClass, String typeName)
	{
		Set<OWLClass> subclasses = buildSubclassValueSetKicker(rootClass,SubclassType.ALL_EXC_ROOT);
		SimpleType valueSet = enumTypeFromClassSet(rootClass,subclasses,typeName);
		return valueSet;
		/*
		// create string enumeration type
		StringEnumerationType enumType = new StringEnumerationType(
				typeName, rootClass.getIRI().toString());
		Set<OWLClassExpression> subclasses = rootClass.getSubClasses(ont);
		
		// filter, remove root
		Set<OWLClass> nonRoots = new HashSet<OWLClass>();
		for(OWLClassExpression subclass : subclasses)
		{
			// note presently we assume value sets are lists of named classes, no set combinations i.e. unions or intersections
			// TODO: deal with more complex class expressions in value sets
			if(subclass instanceof OWLClass)
			{
				if(!subclass.asOWLClass().equals(rootClass))
					nonRoots.add(subclass.asOWLClass());
			}
		}
		
		// create string enumeration from subclasses' names
		Map<String,IRI> enumElements = new HashMap<String,IRI>();
		for(OWLClass nonRoot : nonRoots)
		{
			Set<OWLAnnotation> nonRootLabels = nonRoot.getAnnotations(ont, df.getRDFSLabel());
			
			// for now we presume only one label and no internationalization (i.e. English labels only)
			if(nonRootLabels.size()==0)
				continue;
			
			String label = ((OWLLiteral)nonRootLabels.iterator().next().getValue()).getLiteral();		
			IRI nonRootIRI = nonRoot.getIRI();
			
			enumElements.put(label, nonRootIRI);
		}
		enumType.setEnumElements(enumElements);
		
		return enumType;
		*/
	}
	
	private SimpleType enumTypeFromClassSet(OWLClass rootClass, Set<OWLClass> subclasses, String typeName)
	{
		// create string enumeration type
		StringEnumerationType enumType = new StringEnumerationType(
				typeName, rootClass.getIRI().toString());
		
		
		// create string enumeration from subclasses' names
		Map<String,IRI> enumElements = new HashMap<String,IRI>();
		for(OWLClass subclass : subclasses)
		{
			Set<OWLAnnotation> subLabels = subclass.getAnnotations(ont, df.getRDFSLabel());
			
			// for now we presume only one label and no internationalization (i.e. English labels only)
			if(subLabels.size()==0)
				continue;
			
			String label = ((OWLLiteral)subLabels.iterator().next().getValue()).getLiteral();		
			IRI subIRI = subclass.getIRI();
			
			enumElements.put(label, subIRI);
		}
		enumType.setEnumElements(enumElements);
		
		return enumType;
	}
	
	/*
	 * Assumes hierarchy of basic named classes for now, no set union or intersection or other more complicated constructs
	 */
	private Set<OWLClass> buildSubclassValueSetKicker(OWLClass root, SubclassType st)
	{
		Set<OWLClass> directSubsInVS = new HashSet<OWLClass>();
		if(st.equals(SubclassType.ALL_INC_ROOT))
			directSubsInVS.add(root);
		directSubsInVS.addAll(buildSubclassValueSet(root,st));
		
		return directSubsInVS;
	}
	
	/*
	 * Assumes hierarchy of basic named classes for now, no set union or intersection or other more complicated constructs
	 */
	private Set<OWLClass> buildSubclassValueSet(OWLClass root, SubclassType st)
	{
		Set<OWLClass> subsInVS = new HashSet<OWLClass>();
		Set<OWLClassExpression> subExpressions = root.getSubClasses(ont);
		for(OWLClassExpression subExpression : subExpressions)
		{
			if(subExpression instanceof OWLClass)
			{
				if(st.equals(SubclassType.LEAVES))
				{
					// add in this class if it is a leaf
					OWLClass sub = subExpression.asOWLClass();
					Set<OWLClassExpression> subsubs = sub.getSubClasses(ont);
					boolean isleaf = true;
					for(OWLClassExpression subsub : subsubs)
					{
						if(!(subsub.isBottomEntity()||subsub.isOWLNothing()))
								isleaf=false;
					}
					if(isleaf)
						subsInVS.add(sub);
					else
						subsInVS.addAll(buildSubclassValueSet(sub,st));
					
				}
				else
				{
					// adding all subclasses
					OWLClass sub = subExpression.asOWLClass();
					subsInVS.add(sub);
					subsInVS.addAll(buildSubclassValueSet(sub,st));
				}
			}
			else
			{
				// TODO
			}
				
		}
		
		return subsInVS;
	}

}
