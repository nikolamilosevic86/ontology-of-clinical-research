package edu.stanford.bmir.ocre.util;

import java.io.File;

import org.semanticweb.owlapi.apibinding.OWLManager;
import org.semanticweb.owlapi.model.IRI;
import org.semanticweb.owlapi.model.OWLAnnotationProperty;
import org.semanticweb.owlapi.model.OWLDataFactory;
import org.semanticweb.owlapi.model.OWLOntologyIRIMapper;
import org.semanticweb.owlapi.model.OWLOntologyManager;
import org.semanticweb.owlapi.util.AutoIRIMapper;

public class ImportAnnotations {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		OWLOntologyManager manager = OWLManager.createOWLOntologyManager();
		OWLDataFactory df = manager.getOWLDataFactory();
		OWLAnnotationProperty OCReDef = df.getOWLAnnotationProperty(IRI
				.create("http://purl.org/net/OCRe/statistics.owl#definition"));
		OWLAnnotationProperty OCReComment = df.getOWLAnnotationProperty(IRI
				.create("http://www.w3.org/2000/01/rdf-schema#comment"));
		OWLAnnotationProperty OCReCurator = df.getOWLAnnotationProperty(IRI
				.create("http://purl.org/net/OCRe/statistics.owl#curator"));
		OWLAnnotationProperty OCReDevComment = df
				.getOWLAnnotationProperty(IRI
						.create("http://purl.org/net/OCRe/study_protocol.owl#develop_comment"));
		OWLAnnotationProperty labelProp = df.getOWLAnnotationProperty(IRI
				.create("http://www.w3.org/2000/01/rdf-schema#label"));

		File ontDir = new File("C:/My Dropbox/OCRe/trunk/test");
		// We can also specify a flag to indicate whether the directory should
		// be searched recursively.
		OWLOntologyIRIMapper autoIRIMapper = new AutoIRIMapper(ontDir, false);
		// We can now use this mapper in the usual way, i.e.
		manager.addIRIMapper(autoIRIMapper);

	}

}
