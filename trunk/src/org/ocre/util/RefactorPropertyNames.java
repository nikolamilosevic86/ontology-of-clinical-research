/**
 * 
 */
package edu.stanford.bmir.ocre.util;
import org.semanticweb.owlapi.apibinding.OWLManager;
import org.semanticweb.owlapi.io.*;
import org.semanticweb.owlapi.model.*;
import org.semanticweb.owlapi.util.AutoIRIMapper;
import org.semanticweb.owlapi.util.OWLEntityRenamer;
import org.protege.editor.owl.ui.rename.*;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.net.UnknownHostException;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * @author swt
 *
 */
public class RefactorPropertyNames {

	/**
	 * @param args
	 */
	private static int seed = 10000;
	private static String ontologyName = "";

	public static void main(String[] args) {
		try {
			OWLOntologyManager manager = OWLManager.createOWLOntologyManager();
			OWLDataFactory df = manager.getOWLDataFactory();
			// OCRe:definition => IAO_0000115
			// OCRe:comment => IAO_0000116
			// OCRe:curator => IAO_0000117
			// OCRe:develop_comment => IAO_0000232
			OWLAnnotationProperty IAODef =  df.getOWLAnnotationProperty(IRI.create("http://purl.obolibrary.org/obo/IAO_0000115")); ;
			OWLAnnotationProperty IAODefNote =  df.getOWLAnnotationProperty(IRI.create("http://purl.obolibrary.org/obo/IAO_0000116")); ;
			OWLAnnotationProperty IAODefAuthor =  df.getOWLAnnotationProperty(IRI.create("http://purl.obolibrary.org/obo/IAO_0000117")); ;
			OWLAnnotationProperty IAOCurateNote =  df.getOWLAnnotationProperty(IRI.create("http://purl.obolibrary.org/obo/IAO_0000232")); ;
			OWLAnnotationProperty OCReDef = df.getOWLAnnotationProperty(IRI.create("http://purl.org/net/OCRe/statistics.owl#definition"));
			OWLAnnotationProperty OCReComment = df.getOWLAnnotationProperty(IRI.create("http://www.w3.org/2000/01/rdf-schema#comment"));
			OWLAnnotationProperty OCReCurator = df.getOWLAnnotationProperty(IRI.create("http://purl.org/net/OCRe/statistics.owl#curator"));
			OWLAnnotationProperty OCReDevComment = df.getOWLAnnotationProperty(IRI.create("http://purl.org/net/OCRe/study_protocol.owl#develop_comment"));
			OWLAnnotationProperty labelProp = df.getOWLAnnotationProperty(IRI.create("http://www.w3.org/2000/01/rdf-schema#label"));
			
			
			File ontDir = new File("C:/My Dropbox/OCRe/trunk/test");
			// We can also specify a flag to indicate whether the directory should be searched recursively.
			OWLOntologyIRIMapper autoIRIMapper = new AutoIRIMapper(ontDir, false);
			// We can now use this mapper in the usual way, i.e.
			manager.addIRIMapper(autoIRIMapper);

			File IAOFile = new File("C:/My Dropbox/OCRe/trunk/test/ontology-metadata.owl");
			OWLOntology IAO = manager.loadOntologyFromOntologyDocument(IAOFile);
			OWLOntologyID IAOID = IAO.getOntologyID();
			// We can also load ontologies from files.  Download the OCRe ontology from
			// http://www.co-ode.org/ontologies/OCRe/OCRe.owl and put it somewhere on your hard drive
			// Create a file object that points to the local copy
			File file = new File("C:/My Dropbox/OCRe/trunk/test/OCRe-Start-Here.owl");
			//File file = new File("C:/My Dropbox/OCRe/trunk/test/test1.owl");
			// Now load the local copy
			OWLOntology localOCRe = manager.loadOntologyFromOntologyDocument(file);
			System.out.println("Loaded ontology: " + localOCRe);

			// We can always obtain the location where an ontology was loaded from
			IRI documentIRI = manager.getOntologyDocumentIRI(localOCRe);
			System.out.println("    from: " + documentIRI);
			
			// Get all imported ontologies
			Set<OWLOntology> imports = localOCRe.getImports();
			imports.add(localOCRe);
			for (OWLOntology ont : imports){
				System.out.println("******* "+ont.getOntologyID().getOntologyIRI());
				if (ont.getOntologyID().equals(IAOID))
					continue;
				String root = getIRIRoot(ont.getOntologyID().getOntologyIRI().toString());
				if (root.equals("research")){
					System.out.println("******* "+root);
					setOntName(root);
					File localFile = new File(ontDir+"/"+root+".owl");
					resetSeed();
					Set<OWLClass> clses = ont.getClassesInSignature();
					for (OWLEntity cls : clses) {
						System.out.println(cls.getIRI());
						moveAnnotations(manager, df, ont, cls, OCReDef, IAODef);
						moveAnnotations(manager, df, ont, cls, OCReComment, IAODefNote);
						moveAnnotations(manager, df, ont, cls, OCReCurator, IAODefAuthor);
						moveAnnotations(manager, df, ont, cls, OCReDevComment, IAOCurateNote);
						//Call renameURI(..)
						
						setLabelProp(manager, df, ont, cls, labelProp);
						if (cls.getIRI().toString().contains(root)) {
							IRI newNameIRI = getNewNameIRI(ont.getOntologyID().getOntologyIRI());
							System.out.println("Renaming "+cls.getIRI().toString()+ " to "+newNameIRI);
							renameURI(cls, newNameIRI, manager);
						}
					}
					OWLOntologyFormat format = manager.getOntologyFormat(ont);
					manager.saveOntology(ont, format, IRI.create(localFile));
				}
			}

		}
		catch (OWLOntologyCreationIOException e) {
			// IOExceptions during loading get wrapped in an OWLOntologyCreationIOException
			IOException ioException = e.getCause();
			if(ioException instanceof FileNotFoundException) {
				System.out.println("Could not load ontology. File not found: " + ioException.getMessage());
			}
			else if(ioException instanceof UnknownHostException) {
				System.out.println("Could not load ontology. Unknown host: " + ioException.getMessage());
			}
			else {
				System.out.println("Could not load ontology: " + ioException.getClass().getSimpleName() + " " + ioException.getMessage());    
			}
		}
		catch (UnparsableOntologyException e) {
			// If there was a problem loading an ontology because there are syntax errors in the document (file) that
			// represents the ontology then an UnparsableOntologyException is thrown
			System.out.println("Could not parse the ontology: " + e.getMessage());
			// A map of errors can be obtained from the exception
			Map<OWLParser, OWLParserException> exceptions = e.getExceptions();
			// The map describes which parsers were tried and what the errors were
			for(OWLParser parser : exceptions.keySet()) {
				System.out.println("Tried to parse the ontology with the " + parser.getClass().getSimpleName() + " parser");
				System.out.println("Failed because: " + exceptions.get(parser).getMessage());
			}
		}
		catch (UnloadableImportException e) {
			// If our ontology contains imports and one or more of the imports could not be loaded then an
			// UnloadableImportException will be thrown (depending on the missing imports handling policy)
			System.out.println("Could not load import: " + e.getImportsDeclaration());
			// The reason for this is specified and an OWLOntologyCreationException
			OWLOntologyCreationException cause = e.getOntologyCreationException();
			System.out.println("Reason: " + cause.getMessage());
		}
		catch (OWLOntologyCreationException e) {
			System.out.println("Could not load ontology: " + e.getMessage());
		} 
		catch (OWLOntologyStorageException e) {
			System.out.println("Could not save ontology: " + e.getMessage());
			e.printStackTrace();
		}
	}
	
	private static void renameURI(OWLEntity entityToRename, IRI newNameIRI, OWLOntologyManager mngr) {
		OWLEntityRenamer owlEntityRenamer = new OWLEntityRenamer(mngr,	mngr.getOntologies());
		if (newNameIRI == null) {
			return;
		}
		final List<OWLOntologyChange> changes;
		changes = owlEntityRenamer.changeIRI(entityToRename.getIRI(), newNameIRI);
		mngr.applyChanges(changes);
	}
	
	private static IRI getNewNameIRI( IRI ontIRI){
		seed++;
		
		return IRI.create(ontIRI+ "#" + "OCREP" + seed);
	}
	
	private static void setOntName(String ont) {
		ontologyName = "OCRE_"+ont.toUpperCase();
	}
	
	private static void resetSeed() {
		seed = 399999;
	}
	
	private static void setLabelProp(OWLOntologyManager mngr, OWLDataFactory df, OWLOntology ont, OWLEntity ent, OWLAnnotationProperty labelProp) {
		String labelString ="";
		Set<OWLAnnotation> labels = ent.getAnnotations(ont, labelProp);
		if (labels.isEmpty()) {
			String URIFragment = df.getOWLLiteral(ent.getIRI().getFragment(), "").getLiteral();
			if (URIFragment != null)
				labelString = URIFragment.replace("_", " ");
			OWLLiteral label = df.getOWLLiteral(labelString, "");
			OWLAnnotation labelAnno = df.getOWLAnnotation(labelProp, label);
			OWLAxiom ax = df.getOWLAnnotationAssertionAxiom(ent.getIRI(), labelAnno);
			mngr.applyChange(new AddAxiom(ont, ax));
		}
	}
	
	private static void moveAnnotations(OWLOntologyManager mngr, OWLDataFactory df, OWLOntology ont, OWLEntity ent,  OWLAnnotationProperty OCReProp, OWLAnnotationProperty IAOProp) {
		Set<OWLAnnotation> annots = ent.getAnnotations(ont, OCReProp);
		OWLAnnotationValue val;
		if (!annots.isEmpty()) {
			for (OWLAnnotation annot : annots) {
				if (annot.getValue() instanceof OWLLiteral) {
					val = (OWLLiteral) annot.getValue();
					OWLAnnotation IAOAnnot = df.getOWLAnnotation(IAOProp, val);
					OWLAxiom ax = df.getOWLAnnotationAssertionAxiom(ent.getIRI(), IAOAnnot);
					mngr.applyChange(new AddAxiom(ont, ax));
					Set<OWLAnnotationAssertionAxiom> annotAxioms = ont.getAnnotationAssertionAxioms(ent.getIRI());
					for (OWLAnnotationAssertionAxiom oldax : annotAxioms) {
						//OWLAxiom oldax = df.getOWLAnnotationAssertionAxiom(ent.getIRI(), annot);
						if (oldax.getAnnotation().getProperty().equals(annot.getProperty())) {
							System.out.println(oldax.getProperty().toString() + ":: " +oldax.getValue().toString());
							mngr.applyChange(new RemoveAxiom(ont, oldax));	
						}
					}
				} else System.out.print("Non-literal annotation "+OCReProp+" "+annot.getValue());
			}
		}
	}
	
	private static String getIRIRoot(String scheme){
		System.out.println(scheme);
		String root = "";
		int lastSlash = scheme.lastIndexOf("/");
		int lastDot = scheme.lastIndexOf(".");
		if (lastDot < lastSlash)
			root = scheme.substring(lastSlash+1);
		else
			root = scheme.substring(lastSlash +1, lastDot);
		return root;
	}
}
