/**
 * 
 */
package edu.uw.sig.ocre.datamodel;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.semanticweb.owlapi.apibinding.OWLManager;
import org.semanticweb.owlapi.model.IRI;
import org.semanticweb.owlapi.model.OWLAnnotation;
import org.semanticweb.owlapi.model.OWLAnnotationAssertionAxiom;
import org.semanticweb.owlapi.model.OWLAnnotationProperty;
import org.semanticweb.owlapi.model.OWLAnnotationValue;
import org.semanticweb.owlapi.model.OWLAxiom;
import org.semanticweb.owlapi.model.OWLClass;
import org.semanticweb.owlapi.model.OWLClassExpression;
import org.semanticweb.owlapi.model.OWLDataFactory;
import org.semanticweb.owlapi.model.OWLDataProperty;
import org.semanticweb.owlapi.model.OWLDatatype;
import org.semanticweb.owlapi.model.OWLEntity;
import org.semanticweb.owlapi.model.OWLImportsDeclaration;
import org.semanticweb.owlapi.model.OWLIndividual;
import org.semanticweb.owlapi.model.OWLLiteral;
import org.semanticweb.owlapi.model.OWLNamedIndividual;
import org.semanticweb.owlapi.model.OWLObjectAllValuesFrom;
import org.semanticweb.owlapi.model.OWLObjectProperty;
import org.semanticweb.owlapi.model.OWLObjectUnionOf;
import org.semanticweb.owlapi.model.OWLOntology;
import org.semanticweb.owlapi.model.OWLOntologyCreationException;
import org.semanticweb.owlapi.model.OWLOntologyIRIMapper;
import org.semanticweb.owlapi.model.OWLOntologyLoaderConfiguration;
import org.semanticweb.owlapi.model.OWLOntologyManager;
import org.semanticweb.owlapi.model.OWLProperty;
import org.semanticweb.owlapi.reasoner.OWLReasoner;
import org.semanticweb.owlapi.util.AutoIRIMapper;
import org.semanticweb.owlapi.util.InferredAxiomGenerator;
import org.semanticweb.owlapi.util.InferredEquivalentClassAxiomGenerator;
import org.semanticweb.owlapi.util.InferredOntologyGenerator;
import org.semanticweb.owlapi.util.InferredSubClassAxiomGenerator;
import org.semanticweb.owlapi.util.OWLOntologyMerger;

import com.clarkparsia.pellet.owlapiv3.PelletReasoner;
import com.clarkparsia.pellet.owlapiv3.PelletReasonerFactory;
import com.google.common.collect.HashMultimap;
import com.google.common.collect.Multimap;

import edu.uw.sig.ocre.datamodel.util.StringUtils;
import edu.uw.sig.ocre.datamodel.util.ValueSetGenerator;

/**
 * @author detwiler
 * @date Jun 30, 2011
 */
public class DataModelGenerator
{
	private String extAnnotBase = "http://purl.org/net/OCRe/OCRe_ext.owl#";
	private String hsdbAnnotBase = "http://purl.org/net/OCRe/HSDB_OCRe.owl#";
	private String owlBase = "http://www.w3.org/2002/07/owl#";
	private String exportAnnotBase = "http://purl.org/net/OCRe/export_annotations_def.owl#";
	private OWLOntology ont;
	private OWLOntology seedOnt;
	//private OWLOntologyManager man;
	private OWLDataFactory df;
	
	// the reasoner
	private OWLReasoner reasoner;
	
	private OWLAnnotationProperty xsdRootProp;
	private OWLAnnotationProperty dataElemProp;
	private OWLAnnotationProperty elemOrderProp;
	private OWLAnnotationProperty hasSingleParentProp;
	private OWLAnnotationProperty hasSubclassProp;
	private OWLAnnotationProperty selectGroupProp;
	private OWLAnnotationProperty hasValueSetTypeProp;
	
	private OWLAnnotationProperty dataAttributeProp;
	private OWLDataProperty attributeNameProp;
	private OWLDataProperty attributeTypeProp;
	
	private OWLAnnotationProperty importedElementTypeProp;
	
	private OWLAnnotationProperty xsdImportProp;
	private OWLDataProperty importNamespacePrefixProp;
	private OWLDataProperty importNamespaceProp;
	private OWLDataProperty importLocationProp;
	
	private OWLObjectProperty allValuesFrom;
	
	//private Set<SimpleType> simpleTypes = new HashSet<SimpleType>();
	//private Set<ComplexTypeSequence> complexTypes = new HashSet<ComplexTypeSequence>();
	//private Map<Element,Type> element2Type = new HashMap<Element,Type>();
	//private Map<Type,List<Element>> type2ElementList = new HashMap<Type,List<Element>>();
	private Element rootElement = null;
	private Multimap<OWLClass,Type> namedTypes = HashMultimap.<OWLClass,Type>create();
	private Set<XSDImport> importSet = new HashSet<XSDImport>();
	
	ValueSetGenerator vsGen;
	
	// for imports
	private File importDir;

	public boolean init(String ontURL)
	{
		// Create our manager
		OWLOntologyManager man = OWLManager.createOWLOntologyManager();
		
		// create an auto mapper for imports

		// We can also specify a flag to indicate whether the directory should be searched recursively.
		OWLOntologyIRIMapper autoIRIMapper = new AutoIRIMapper(importDir, false);
		
		// We can now use this mapper in the usual way, i.e.
		man.addIRIMapper(autoIRIMapper); 
		
		// Load the OCRe ontology
		try
		{
			//OWLOntology seedOnt = man.loadOntologyFromOntologyDocument(IRI.create(ontURL));
			seedOnt = man.loadOntologyFromOntologyDocument(IRI.create(ontURL));
			
			// create the Pellet reasoner
			reasoner = PelletReasonerFactory.getInstance().createNonBufferingReasoner( seedOnt );
			
			// Ask the reasoner to do all the necessary work now
			//reasoner.precomputeInferences();

			/*
			// Use an inferred axiom generators 
			//List<InferredAxiomGenerator<? extends OWLAxiom>> gens = Collections.singletonList(new InferredClassAxiomGenerator()); 
			List<InferredAxiomGenerator<? extends OWLAxiom>> gens = new ArrayList<InferredAxiomGenerator<? extends OWLAxiom>>();
            gens.add(new InferredSubClassAxiomGenerator());
            gens.add(new InferredEquivalentClassAxiomGenerator());

			OWLOntology infOnt = man.createOntology(); 
			// create the inferred ontology generator 
			InferredOntologyGenerator iog =  new InferredOntologyGenerator(reasoner, gens);
			iog.fillOntology(man, infOnt);
			*/
			
			InferredOntologyGenerator generator = new InferredOntologyGenerator( reasoner );
			OWLOntology infOnt = man.createOntology(IRI.create("http://si.uw.edu/hsdb_ocre_infer"));
			generator.fillOntology( man, infOnt );
			
			/*
			// Print out the axioms in the merged ontology.
			for (OWLAxiom ax : infOnt.getAxioms()) {
				System.out.println(ax);
			}
			*/
			
			
			/*
			// test merging of imports
			OWLOntologyMerger merger = new OWLOntologyMerger(man);
			
			Set<OWLOntology> imports = seedOnt.getImportsClosure();
			
			Set<OWLImportsDeclaration> importsDecls = seedOnt.getImportsDeclarations();
			OWLOntologyLoaderConfiguration loaderConfig = new OWLOntologyLoaderConfiguration();
			Iterator<OWLImportsDeclaration> importsDeclsIt = importsDecls.iterator();
			while(importsDeclsIt.hasNext())
			{
				OWLImportsDeclaration decl = importsDeclsIt.next();
				IRI importIRI = decl.getIRI();
				if(!man.contains(importIRI))
				{
					man.makeLoadImportRequest(decl, new OWLOntologyLoaderConfiguration());
					OWLOntology importOnt = man.getOntology(decl.getIRI());
					importsDecls.addAll(importOnt.getImportsDeclarations());
				}
				else
				{
					// found import cycle
					// this is not an error, just testing
					System.err.println("found import cycle");
				}
			}
			
			*/
			/*
			for(OWLImportsDeclaration decl : importsDecls)
			{
				man.makeLoadImportRequest(decl, new OWLOntologyLoaderConfiguration());
			}*/
			
			OWLOntologyMerger merger = new OWLOntologyMerger(man);
			IRI mergedOntologyIRI = IRI.create("http://si.uw.edu/hsdb_ocre_merged");
			ont = merger.createMergedOntology(man, mergedOntologyIRI);
			
			
			// Print out the axioms in the merged ontology.
			/*
			for (OWLAxiom ax : ont.getAxioms()) {
				System.out.println(ax);
			}*/
			
		}
		catch (OWLOntologyCreationException e)
		{
			e.printStackTrace();
			return false;
		}
		
		df = man.getOWLDataFactory();
		
		xsdRootProp = df.getOWLAnnotationProperty(IRI.create(exportAnnotBase + "OCRE529769"));
		
		if(xsdRootProp==null)
		{
			System.err.println("Error, xsd root property not found");
			return false;
		}
		
		// get the other data model annotation properties
		dataElemProp = df.getOWLAnnotationProperty(IRI.create(exportAnnotBase + "OCRE520413"));
		elemOrderProp = df.getOWLAnnotationProperty(IRI.create(exportAnnotBase + "OCRE863610"));
		hasSingleParentProp = df.getOWLAnnotationProperty(IRI.create(exportAnnotBase + "OCRE566765"));
		hasSubclassProp = df.getOWLAnnotationProperty(IRI.create(hsdbAnnotBase + "OCRE875514"));
		selectGroupProp = df.getOWLAnnotationProperty(IRI.create(exportAnnotBase + "OCRE585583"));
		hasValueSetTypeProp = df.getOWLAnnotationProperty(IRI.create(exportAnnotBase + "OCRE826078"));
		
		dataAttributeProp = df.getOWLAnnotationProperty(IRI.create(exportAnnotBase + "OCRE842711"));
		attributeNameProp = df.getOWLDataProperty(IRI.create(exportAnnotBase + "OCRE253353"));
		attributeTypeProp = df.getOWLDataProperty(IRI.create(exportAnnotBase + "OCRE956877"));
		
		importedElementTypeProp = df.getOWLAnnotationProperty(IRI.create(exportAnnotBase + "OCRE000041"));
		
		xsdImportProp = df.getOWLAnnotationProperty(IRI.create(exportAnnotBase + "OCRE000003"));
		importNamespacePrefixProp = df.getOWLDataProperty(IRI.create(exportAnnotBase + "OCRE000021"));
		importNamespaceProp = df.getOWLDataProperty(IRI.create(exportAnnotBase + "OCRE000019"));
		importLocationProp = df.getOWLDataProperty(IRI.create(exportAnnotBase + "OCRE000020"));
		
		if(
				dataElemProp==null||
				elemOrderProp==null||
				hasSingleParentProp==null||
				hasSubclassProp==null||
				selectGroupProp==null||
				hasValueSetTypeProp==null||
				dataAttributeProp==null||
				attributeNameProp==null||
				attributeTypeProp==null||
				xsdImportProp==null||
				importNamespacePrefixProp==null||
				importNamespaceProp==null||
				importLocationProp==null
		)
		{
			System.err.println("important slot not found");
			return false;
		}
		
		// owl properties
		allValuesFrom = df.getOWLObjectProperty(IRI.create(owlBase+"allValuesFrom"));
		
		vsGen = new ValueSetGenerator(ont,df);

		return true;
	}
	
	private XSDImport processImportAnnotation(OWLIndividual importAnnot)
	{
		String location = ((OWLLiteral)importAnnot.getDataPropertyValues(importLocationProp, ont)
				.iterator().next()).getLiteral();
		String namespace = ((OWLLiteral)importAnnot.getDataPropertyValues(importNamespaceProp, ont)
				.iterator().next()).getLiteral();
		String prefix = ((OWLLiteral)importAnnot.getDataPropertyValues(importNamespacePrefixProp, ont)
				.iterator().next()).getLiteral();
		XSDImport xsdimport = new XSDImport(location,namespace,prefix);
		return xsdimport;
	}

	public void extractDataModel(String ontURL, String ontImportFileDirectory)
	{
		importDir = new File(ontImportFileDirectory);
		
		String results = null;
		if (init(ontURL))
		{
			// find the xsd root
			OWLProperty rootProperty = null;
			for(OWLAnnotation ontAnnot : reasoner.getRootOntology().getAnnotations())
			{
				if(ontAnnot.getProperty().equals(xsdRootProp))
				{
					rootProperty = df.getOWLObjectProperty((IRI)ontAnnot.getValue());
					// should not be more than one tagged root
				}
				// check for import annotations
				else if(ontAnnot.getProperty().equals(xsdImportProp))
				{
					OWLAnnotationValue value = ontAnnot.getValue();
					OWLIndividual importSpec = df.getOWLNamedIndividual((IRI)value);
					importSet.add(processImportAnnotation(importSpec));
				}
			}
			
			if(rootProperty == null)
			{
				System.err.println("Error loading root property");
			}
			
			Element subElement = createElementForProperty(rootProperty, null);
			List<Element> subElements = new ArrayList<Element>();
			subElements.add(subElement);
			rootElement = createRootElement(subElements);
			
			/*
			// root tag no longer fabricated from specification external to data model annotations
			// ontology used to tag class roots that were not xml roots
			// ontology now tags property that will be xml root

			Set<OWLClass> xsdRootClses = new HashSet<OWLClass>();
			for(OWLAnnotation owlOnt : ont.getAnnotations())
			{
				if(owlOnt.getProperty().equals(xsdRootProp))
					xsdRootClses.add(df.getOWLClass((IRI)owlOnt.getValue()));
			}
			
			if(xsdRootClses.isEmpty())
			{
				System.err.println("Error loading root class(es)");
			}
			
			// begin recursive process from each root
			List<Type> rootTypes = new ArrayList<Type>();
			
			for(OWLClass root : xsdRootClses)
			{
				Type rootType = createTypeFromClass(root);
				rootTypes.add(rootType);
			}
			
			rootElement = createRootElement(rootTypes);
			*/
		}

	}
	
	
	private Element createRootElement(List<Element> rootElems/*List<Type> subRootTypes*/)
	{
		/*
		 * <xsd:complexType name="HSDBWeb"><xsd:sequence><xsd:element name="StudyInfo" type="Study" maxOccurs="unbounded"/></xsd:sequence></xsd:complexType><xsd:element name="HSDBWeb" type="HSDBWeb"/>
		 */
		
		ComplexTypeSequence type = new ComplexTypeSequence();
		type.setName("RootType");
		namedTypes.put(null,type);
		
		type.setSequence(rootElems);
		Element rootElem = new Element("Root",type,null);
		rootElem.setMinOccurs(null);
		rootElem.setMaxOccurs(null);
		
		return rootElem;
		
		/*
		ComplexTypeSequence type = new ComplexTypeSequence();
		type.setName("HSDBWebType");
//		namedTypes.add(type);
		for(Type subType : subRootTypes)
		{
			Element subRootElem = new Element(subType.getName(),subType,null);
			type.getSequence().add(subRootElem);
		}
		Element HSDBWeb = new Element("HSDBWeb",type,null);
		
		return HSDBWeb;
		*/
	}
	
	private Element createElementForProperty(OWLProperty currProperty, OWLClass currClass)
	{
		//TODO: this method could be cleaned up, repeated calls could be pulled from if/then and done once
		
		// test code
		/*
		OWLObjectProperty componentProp = df.getOWLObjectProperty(IRI.create("http://purl.org/net/OCRe/study_protocol.owl#OCRE859340"));
		if(componentProp==currProperty)
			System.err.println("creating element for Component");
			*/
		
		// get/create element name
		String name = createElementNameFromLabel(currProperty);	
		String uri = currProperty.getIRI().toString();
		
		// determine if Element should have any attributes
		List<Attribute> attrList = getAttributesForElement(currProperty);
		
		// determine if there is a remote type
		Type remoteType = getRemoteType(currProperty);
		if(remoteType!=null)
		{
			// remote type
			
			Element newElem = new Element(name,remoteType,uri);
			return newElem;	
		}
		else
		{
			// local type
			
			// get the range of the property
			Set ranges = currProperty.getRanges(ont);
			
			// need to check for local overrides (universal restrictions)
			if(currClass!=null) // null class occurs only on root property
			{
				Set localRanges = getLocalRange(currClass, currProperty);
				if(!localRanges.isEmpty())
					ranges = localRanges;
			}
			
			/*
			Set<OWLClassExpression> superClasses = currClass.getSuperClasses(ont);
			if(currProperty instanceof OWLObjectProperty)
			{
				df.getOWLObjectAllValuesFrom((OWLObjectProperty)currProperty, currClass);
			}
			*/
				
			if(ranges.size()==1)
			{
				// ranges with a single named class are the easy case
				Object rangeObject = ranges.iterator().next();
				if(rangeObject instanceof OWLEntity)
				{
					OWLEntity range = (OWLEntity)rangeObject;
					
					String typeName = null;
					Type type = null;
					if(range instanceof OWLLiteral)
						typeName = ((OWLLiteral)range).getDatatype().toString();
					else if(range instanceof OWLClass)
					{
						//typeName = createCamelCaseFromLabel(range);
						Type supertype = createTypeFromClass((OWLClass)range);
						if(attrList.isEmpty())
							type=supertype;
						else
							type = createComplexTypeAttrExt(supertype, attrList);
						//type.setAttributeMap(attributeMap);
					}
					else if(range instanceof OWLDatatype)
					{
						//System.err.println("found owl datatype property range");
						Type supertype = new BuiltInType(range.toString());
						if(attrList.isEmpty())
							type=supertype;
						else
							type = createComplexTypeAttrExt(supertype, attrList);
						//type.setAttributeMap(attributeMap);
						//System.err.println(range.toString());
						//return null;
					}
					else
					{
						System.err.println("found unhandled property range type");
						return null;
					}
					
					// create a new element for this property
					Element newElem = new Element(name,type,uri);
					
					//element2Type.put(newElem,type);
					
					return newElem;	
				}
				else if(rangeObject instanceof OWLObjectUnionOf)
				{
					OWLObjectUnionOf rangeUnionOf = (OWLObjectUnionOf)rangeObject;
					Type supertype = createTypeFromObjectUnionOf(rangeUnionOf);
					Type type;
					if(attrList.isEmpty())
						type = supertype;
					else
						type = createComplexTypeAttrExt(supertype, attrList);
					//type.setAttributeMap(attributeMap);
					
					// object union, we will create a choice object, requires a typeless element (nested type)
					Element newElem = new Element(name,type,uri);
					
					//element2Type.put(newElem, type);
					
					return newElem;
					
					/*
					OWLObjectUnionOf rangeUnionOf = (OWLObjectUnionOf)rangeObject;
					ComplexTypeChoice choice = createChoice(rangeUnionOf);
					
					return choice;
					*/
				}
			}
			else if(ranges.size()>1)
			{
				//TODO: figure out how to handle this case
				System.err.println("found property with ranges.size() > 1: "+name +" -> "+ranges);
			}
			
			return null;
		}
	}
	
	/**
	 * Gets the annotations on an ontology class to see what attributes should be added to 
	 * the schema definition of the corresponding xml type
	 * @param currClass
	 * @return
	 */
	private List<Attribute> getAttributesForType(OWLClass currClass)
	{
		List<Attribute> attrList = new ArrayList<Attribute>();
		
		Set<OWLAnnotation> dataAttrAnnots = currClass.getAnnotations(ont, dataAttributeProp);
		if(!dataAttrAnnots.isEmpty())
		{
			for(OWLAnnotation dataAttrAnnot: dataAttrAnnots)
			{
				OWLAnnotationValue value = dataAttrAnnot.getValue();
				if(value instanceof IRI)
				{
				    IRI valueIRI = (IRI)value;
				    Set<OWLEntity> entities = ont.getEntitiesInSignature(valueIRI);
				    for(OWLEntity entity : entities)
				    {
				        if(entity instanceof OWLIndividual)
				        {
				        	OWLIndividual attribute = (OWLIndividual)entity;
				        	Set<OWLLiteral> names = attribute.getDataPropertyValues(attributeNameProp, ont);
				        	Set<OWLLiteral> types = attribute.getDataPropertyValues(attributeTypeProp, ont);
				        	//should be exactly one name and type, if not we will skip this attribute
				        	if(names==null||names.isEmpty()||types==null||types.isEmpty())
				        		continue;
				        	String name = names.iterator().next().getLiteral();
				        	String type = types.iterator().next().getLiteral();
				        	Attribute newAttr = new Attribute(name,type);
				        	attrList.add(newAttr);
				        }
				    }
				}
			}
		}
		
		return attrList;
	}
	
	/**
	 * Gets the annotations on an ontology property to see what attributes should be added to 
	 * the schema definition of the corresponding xml element
	 * @param currProperty
	 * @return
	 */
	private List<Attribute> getAttributesForElement(OWLProperty currProperty)
	{
		List<Attribute> attrList = new ArrayList<Attribute>();
		
		Set<OWLAnnotation> dataAttrAnnots = currProperty.getAnnotations(ont, dataAttributeProp);
		if(!dataAttrAnnots.isEmpty())
		{
			for(OWLAnnotation dataAttrAnnot: dataAttrAnnots)
			{
				OWLAnnotationValue value = dataAttrAnnot.getValue();
				if(value instanceof IRI)
				{
				    IRI valueIRI = (IRI)value;
				    Set<OWLEntity> entities = ont.getEntitiesInSignature(valueIRI);
				    for(OWLEntity entity : entities)
				    {
				        if(entity instanceof OWLIndividual)
				        {
				        	OWLIndividual attribute = (OWLIndividual)entity;
				        	Set<OWLLiteral> names = attribute.getDataPropertyValues(attributeNameProp, ont);
				        	Set<OWLLiteral> types = attribute.getDataPropertyValues(attributeTypeProp, ont);
				        	//should be exactly one name and type, if not we will skip this attribute
				        	if(names==null||names.isEmpty()||types==null||types.isEmpty())
				        		continue;
				        	String name = names.iterator().next().getLiteral();
				        	String type = types.iterator().next().getLiteral();
				        	Attribute newAttr = new Attribute(name,type);
				        	attrList.add(newAttr);
				        }
				    }
				}
			}
		}
		
		return attrList;
	}
	
	
	/**
	 * creates a complex type that will be an extension of supertype plus have all attributes in 
	 * attributes in attribute map
	 * @param supertype The type to extend with attributes
	 * @param attrMap A map of attribute name to attribute datatype
	 * @return
	 */
	private ComplexTypeAttrExt createComplexTypeAttrExt(Type supertype, List<Attribute> attributes)
	{
		ComplexTypeAttrExt newType = new ComplexTypeAttrExt();
		newType.setAttrList(attributes);
		newType.setSuperType(supertype);
		return newType;
	}
	
	private Set getLocalRange(OWLClass currClass, OWLProperty currProperty)
	{
		Set<OWLClassExpression> superExprs = currClass.getSuperClasses(ont);
		Set localRanges = new HashSet();
		for(OWLClassExpression superExpr : superExprs)
		{
			if(superExpr instanceof OWLObjectAllValuesFrom)
			{
				// found universal restriction, process for local range
				if(((OWLObjectAllValuesFrom)superExpr).getProperty().equals(currProperty))
					return superExpr.getClassesInSignature(); 
				
				// NOTE: we do not presently handle case of multiple universal restrictions on same property for same class 
				//(which would be intersection of local ranges)
			}
		}
		
		return localRanges;
	}
	
	private Type getRemoteType(OWLProperty currProperty)
	{
		Set<OWLAnnotation> impElemTypeAnnots = currProperty.getAnnotations(ont, importedElementTypeProp);
		String typeName = null;
		if(!impElemTypeAnnots.isEmpty())
		{
			for(OWLAnnotation impElemTypeAnnot: impElemTypeAnnots)
			{
				OWLAnnotationValue value = impElemTypeAnnot.getValue();
				
				if(value instanceof OWLLiteral)
				{
					typeName = ((OWLLiteral)value).getLiteral();
					break;
				}
			}
		}
		if(typeName==null)
			return null;
		else
		{
			RemoteType remoteType = new RemoteType(typeName);
			return remoteType;	
		}
	}
	
	private Type createTypeFromClass(OWLClass currClass)
	{		
		// do not recreate if type has already been created
		if(namedTypes.containsKey(currClass))
		{
			// find the type with the same uri as this class and return it
			IRI currClassIRI = currClass.getIRI();
			for(Type assocType : namedTypes.get(currClass))
			{
				if(currClassIRI.toString().equals(assocType.getUri()))
				{
					return assocType;
				}
			}
			//return namedTypes.get(currClass);
		}
		
		// determine if Element should have any attributes
		List<Attribute> attrList = getAttributesForType(currClass);
		
		boolean isValueSet = false;
		boolean isChoice = false;
		boolean isSequence = false;
		if(currClass.getAnnotations(ont, hasValueSetTypeProp).size()>0)
			isValueSet = true;
		if(!isValueSet) // then it is a complex type
		{
			// check for select group annotations
			if(currClass.getAnnotations(ont, selectGroupProp).size()>0)
				isChoice = true;
			
			// if it is annotated with data elements or a single parent (or simply isn't a choice), then it is a sequence
			if(currClass.getAnnotations(ont, dataElemProp).size()>0 || currClass.getAnnotations(ont, hasSingleParentProp).size()>0 || !isChoice)
				isSequence = true;
		}
		
		if(isValueSet)
		{
			SimpleType simpleType = createValueSetFromClass(currClass);
			simpleType.setAttrList(attrList);
			
			// todo move this to the begininning of value set creation method once it exists (DONE?)
			//namedTypes.put(currClass, simpleType);
			return simpleType; 
		}
			
		if(isChoice && !isSequence)
		{
			Type choiceType = createChoiceTypeFromClass(currClass, false);
			//namedTypes.put(currClass, choiceType);
			return choiceType;
		}
		
		if(isSequence)
		{
			ComplexTypeSequence seqType = (ComplexTypeSequence)createSequenceTypeFromClass(currClass);
			seqType.setAttrList(attrList);
			if(isChoice)
			{
				seqType.setSuperType(createChoiceTypeFromClass(currClass, true));
			}
			
			//namedTypes.put(currClass, seqType);
			return seqType;
		}
		
		System.err.println("Encountered non complex type in createTypeFromClass: "+currClass.getIRI().toString());
		return null;
	}
	
	private Type createSequenceTypeFromClass(OWLClass currClass)
	{
		ComplexTypeSequence cType = new ComplexTypeSequence();
		namedTypes.put(currClass, cType);
		
		cType.setName(createTypeNameFromLabel(currClass, true));
		cType.setUri(currClass.getIRI().toString());
		//namedTypes.add(cType);		
		
		//System.err.println("creating sequence type from class "+createTypeNameFromLabel(currClass, true));
		
		// handle "has single parent" annotations
		// so far we assume that all subclass types are extensions
		OWLClass singleParent = getSingleParent(currClass);
		if(singleParent!=null)
		{
			Type singleParentType = createTypeFromClass(singleParent);
			cType.setSuperType(singleParentType);
		}
		
		// handle "has subclass" annotations
		// again, so far we assume that all subclass types are extensions
		Set<OWLClass> subclasses = getSubclasses(currClass);
		for(OWLClass subclass : subclasses)
		{
			//ComplexTypeSequence subclassType = (ComplexTypeSequence)createSequenceTypeFromClass(subclass);
			ComplexTypeSequence subclassType = (ComplexTypeSequence)createTypeFromClass(subclass);
			subclassType.setSuperType(cType);
		}
		
		
		List<OWLProperty> dmElemProps = getDataModelElements(currClass);
		
		// create element for each property and add to new complex type
		//List<Element> elements = new ArrayList<Element>();
		for(OWLProperty dmElemProp : dmElemProps)
		{
			Element newElem = createElementForProperty(dmElemProp, currClass);
			if(newElem!=null)
				cType.getSequence().add(newElem);
			/*
			// add element to complex type
			XSDEntity newEnt = createXSDEntity(dmElemProp);
			if(newEnt!=null)
				cType.getSequence().add(newEnt);
				*/
		}
		//type2ElementList.put(cType, elements);
		
		return cType;
	}
	
	private Type createChoiceTypeFromClass(OWLClass currClass, boolean isIntermediate)
	{
		ComplexTypeChoice cType = new ComplexTypeChoice();
		namedTypes.put(currClass, cType);
		
		Set<OWLAnnotation> selGroupAnnots = currClass.getAnnotations(ont, selectGroupProp);
		Set<Element> choiceElements = new HashSet<Element>();
		if(!selGroupAnnots.isEmpty())
		{
			for(OWLAnnotation selGroupAnnot: selGroupAnnots)
			{
				OWLAnnotationValue value = selGroupAnnot.getValue();
				if(value instanceof IRI)
				{
				    IRI valueIRI = (IRI)value;
				    Set<OWLEntity> entities = ont.getEntitiesInSignature(valueIRI);
				    for(OWLEntity entity : entities)
				    {
				        if(entity instanceof OWLClass)
				        {
				        	OWLClass entClass = (OWLClass)entity;
				        	Type type = createTypeFromClass(entClass);
							
							String typeName = createTypeNameFromLabel(entClass, false);
							String uri = entClass.getIRI().toString();
							String name = typeName;
							
							Element newElem = new Element(name,type,uri);
							
				        	choiceElements.add(newElem);
				        }
				    }
				}
			}
		}
		
		cType.setOptions(choiceElements);
		
		
		if(!isIntermediate) // give this type a name and uri
		{
			cType.setName(createTypeNameFromLabel(currClass,true));
			cType.setUri(currClass.getIRI().toString());
		}
		else
			cType.setName(createTypeNameFromLabel(currClass,true)+"Intermediate");
		
		//namedTypes.add(cType);
		return cType;
	}
	
	private Type createTypeFromObjectUnionOf(OWLObjectUnionOf union)
	{
		Set<OWLClassExpression> disjunctSet = union.asDisjunctSet();
		Set<Element> choiceElements = new HashSet<Element>();
		for(OWLClassExpression member : disjunctSet)
		{
			OWLClass disjunctMember = member.asOWLClass();
			
			Type type = createTypeFromClass(disjunctMember);
			
			String typeName = createTypeNameFromLabel(disjunctMember,false);
			String uri = disjunctMember.getIRI().toString();
			String name = typeName;
			
			Element newElem = new Element(name,type,uri);
			choiceElements.add(newElem);
			
			
			//element2Type.put(newElem, type);
		}
		
		// create choice object
		ComplexTypeChoice choice = new ComplexTypeChoice(choiceElements);
		//namedTypes.add(choice);
		
		return choice;
	}
	
	private OWLClass getSingleParent(OWLClass currClass)
	{
		OWLClass singleParent = null;
		Set<OWLAnnotation> hasSingleParentAnnots = currClass.getAnnotations(ont, hasSingleParentProp);
		
		// there should only be one such annotation, ignore all but first
		if(!hasSingleParentAnnots.isEmpty())
		{
			OWLAnnotationValue value = hasSingleParentAnnots.iterator().next().getValue();
			if(value instanceof IRI)
			{
			    IRI valueIRI = (IRI)value;
			    Set<OWLEntity> entities = ont.getEntitiesInSignature(valueIRI);
			    for(OWLEntity entity : entities)
			    {
			        if(entity instanceof OWLClass)
			        {
			            singleParent = (OWLClass)entity;
			            break;
			        }
			    }
			}
		}
		
		return singleParent;
	}
	
	private Set<OWLClass> getSubclasses(OWLClass currClass)
	{
		Set<OWLClass> subclasses = new HashSet<OWLClass>();
		Set<OWLAnnotation> hasSubclassAnnots = currClass.getAnnotations(ont, hasSubclassProp);
		
		for(OWLAnnotation hasSubclassAnnot : hasSubclassAnnots)
		{
			OWLAnnotationValue value = hasSubclassAnnot.getValue();
			if(value instanceof IRI)
			{
			    IRI valueIRI = (IRI)value;
			    Set<OWLEntity> entities = ont.getEntitiesInSignature(valueIRI);
			    for(OWLEntity entity : entities)
			    {
			        if(entity instanceof OWLClass)
			        {
			            subclasses.add((OWLClass)entity);
			            break;
			        }
			    }
			}
		}
		
		return subclasses;
	}
	
	private SimpleType createValueSetFromClass(OWLClass rootClass)
	{
		// first create the simple type stub (to be returned if we don't find proper annotations)
		SimpleType simpleType = new SimpleType();
		simpleType.setName(createTypeNameFromLabel(rootClass, true));
		simpleType.setUri(rootClass.getIRI().toString());
		//return simpleType;
		
		// check and see what kind of value set we should produce
		Set<OWLAnnotation> valSetAnnots = rootClass.getAnnotations(ont, hasValueSetTypeProp);
		
		// if there is no value set type annotation, just return simple type stub
		if(valSetAnnots == null || valSetAnnots.size()==0)
		{
			namedTypes.put(rootClass, simpleType);
			return simpleType;
		}
		
		// get instance representing value set type
		OWLNamedIndividual namedValSetTypeInd = null;
		
		// if there are more than one value set type annotation we just take first one
		OWLAnnotation valSetAnnot = valSetAnnots.iterator().next();
		OWLAnnotationValue value = valSetAnnot.getValue();
		if(value instanceof IRI)
		{
			IRI valueIRI = (IRI)value;
		    Set<OWLEntity> entities = ont.getEntitiesInSignature(valueIRI);
		    for(OWLEntity entity : entities)
		    {
		        if(entity instanceof OWLNamedIndividual)
		        {
		        	namedValSetTypeInd = (OWLNamedIndividual)entity;
		        	break;
		        }
		    }
		}
		
		// if we failed to find the individual representing the value set type, return stub
		if(namedValSetTypeInd==null)
		{
			namedTypes.put(rootClass, simpleType);
			return simpleType;
		}

		
		if(namedValSetTypeInd.getIRI().toString().equals(extAnnotBase+"OCRE874148"))
		{
			// external query
			// TODO: this case is not yet handled
			namedTypes.put(rootClass, simpleType);
			return simpleType;
		}
		else if(namedValSetTypeInd.getIRI().toString().equals(extAnnotBase+"OCRE877903"))
		{
			// individuals
			
			String typeName = createTypeNameFromLabel(rootClass, true);
			simpleType = vsGen.individualValueSet(rootClass, typeName);
			namedTypes.put(rootClass, simpleType);
			return simpleType;
		}
		else if(namedValSetTypeInd.getIRI().toString().equals(extAnnotBase+"OCRE820798"))
		{
			// leaf subclasses
			
			String typeName = createTypeNameFromLabel(rootClass, true);
			simpleType = vsGen.LeafSubclassValueSet(rootClass, typeName);
			namedTypes.put(rootClass, simpleType);
			return simpleType;
		}
		else if(namedValSetTypeInd.getIRI().toString().equals(extAnnotBase+"OCRE893499"))
		{
			// subclasses excluding root
			
			String typeName = createTypeNameFromLabel(rootClass, true);
			simpleType = vsGen.subclassValueSetExcRoot(rootClass, typeName);
			namedTypes.put(rootClass, simpleType);
			return simpleType;
		}
		else if(namedValSetTypeInd.getIRI().toString().equals(extAnnotBase+"OCRE827797"))
		{
			// subclasses including root
			
			String typeName = createTypeNameFromLabel(rootClass, true);
			simpleType = vsGen.subclassValueSetIncRoot(rootClass, typeName);
			namedTypes.put(rootClass, simpleType);
			return simpleType;
		}
		else
		{
			// invalid annotation
			// TODO: not sure what we should do here
			namedTypes.put(rootClass, simpleType);
			return simpleType;
		}
		
	}
	
	//private Set<OWLClasses> getChoiceElements
	
	private List<OWLProperty> getDataModelElements(OWLClass currClass)
	{
		List<OWLProperty> dmElems = new ArrayList<OWLProperty>();
		Set<OWLAnnotationAssertionAxiom> annotAxioms = currClass.getAnnotationAssertionAxioms(ont);
		for(OWLAnnotationAssertionAxiom annotAxiom: annotAxioms)
		{
			if (annotAxiom.getProperty().equals(dataElemProp))
			{
				//OWLAnnotation dataElemAnnot = annot.getAnnotation();
				/*
				int elemOrder = getElementOrder(annotAxiom);
				
				if(elemOrder != -1)
					System.err.println("found element order = "+elemOrder);
					*/
				
				OWLAnnotationValue value = annotAxiom.getValue();
				if(value instanceof IRI)
				{
				    IRI valueIRI = (IRI)value;
				    Set<OWLEntity> entities = ont.getEntitiesInSignature(valueIRI);
				    for(OWLEntity entity : entities)
				    {
				        if(entity instanceof OWLProperty)
				            dmElems.add((OWLProperty)entity);
				    }
				}
			}
		}

		/*
		Set<OWLAnnotation> dataElemAnnots = currClass.getAnnotations(ont, dataElemProp);
		for(OWLAnnotation dataElemAnnot : dataElemAnnots)
		{
			// test
			getElementOrder(dataElemAnnot);
			
			OWLAnnotationValue value = dataElemAnnot.getValue();
			if(value instanceof IRI)
			{
			    IRI valueIRI = (IRI)value;
			    Set<OWLEntity> entities = ont.getEntitiesInSignature(valueIRI);
			    for(OWLEntity entity : entities)
			    {
			        if(entity instanceof OWLProperty)
			            dmElems.add((OWLProperty)entity);
			    }
			}
		}
		*/
		
		return dmElems;
	}
	
	private int getElementOrder(OWLAnnotationAssertionAxiom dataElemAnnotAxiom)
	{
		int order = -1;
		Set<OWLAnnotation> annotAxiomAnnots = dataElemAnnotAxiom.getAnnotations();
		for(OWLAnnotation annotAxiomAnnot : annotAxiomAnnots)
		{
			OWLAnnotationProperty annotProp = annotAxiomAnnot.getProperty();
			if(annotProp.equals(elemOrderProp))
			{
				// this is the element order property, return its value.
				OWLAnnotationValue value = annotAxiomAnnot.getValue();
				if(value instanceof OWLLiteral)
				{
					OWLLiteral literalValue = (OWLLiteral)value;
					if(literalValue.isInteger())
						order = literalValue.parseInteger();
					System.err.println("what sort of value is this? "+literalValue.getLiteral());
				}
			}
		}
		
		return order;
	}
	
	private String createCamelCaseFromLabel(OWLEntity entity)
	{
		String result = null;
		Set<OWLAnnotation> labels = entity.getAnnotations(ont, df.getRDFSLabel());
		
		// return null if entity has no rdfs label
		if(!labels.isEmpty())
		{		
			// if there are multiple labels, we arbitrarily choose one
			OWLAnnotation labelAnnot = labels.iterator().next();
			
			OWLLiteral labelAnnotLiteral = (OWLLiteral)labelAnnot.getValue();
			result = StringUtils.toCamelCase(labelAnnotLiteral.getLiteral(), true);
		}
		
		return result;
	}
	
	private String createTypeNameFromLabel(OWLClass currClass, boolean appendTypeString)
	{
		String ccName = createCamelCaseFromLabel(currClass);
		if(appendTypeString)
			ccName = ccName.concat("Type");
		return ccName;
	}
	
	private String createElementNameFromLabel(OWLEntity entity)
	{
		String ccName = createCamelCaseFromLabel(entity);
		
		if(ccName.matches("^Has\\p{javaUpperCase}.*"))
			return ccName.substring(3);
		if(ccName.matches("^Is\\p{javaUpperCase}.*"))
			return ccName.substring(2);
		else
			return ccName;
	}
	
	public static void main(String[] args)
	{
		if(!(args.length==2))
		{
			System.err.println("usage: java DataModelGenerator <url_of_owl_file> <local_import_director>");
			System.exit(-1);
		}
		
		String ontURL = args[0];
		String importDir = args[1];
		
		DataModelGenerator dme = new DataModelGenerator();
		dme.extractDataModel(ontURL, importDir);
		
		XSDWriter writer = new XSDWriter();
		String xsd = writer.generateXSDString(dme.importSet, dme.rootElement, dme.namedTypes.values());
		System.err.println(xsd);
		
	}
}
