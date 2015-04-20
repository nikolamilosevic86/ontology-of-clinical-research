# Adding domain, range and annotations #

Developers making changes to the ontology should use a change-tracking service to monitor changes to the OCRe Google code repository.
Samson uses http://www.followthatpage.com/ to monitor http://code.google.com/p/ontology-of-clinical-research/source/browse/#svn/trunk

He gets email notifications when the source repository web page changes.

Classes, properties, and class/property restrictions will be edited consistently in Protege 4.
Protege 3.4 and Protege 4 files are not comparable as text files, thus we won't be able to reconcile conflicting versions of the ontology files if they are created by different tools.

Right now Protege 3.4 can't load the OCRe "research" module. Not sure why.

Protege 4 allows a Refactor option for extracting a subset of an ontology.

Samson is exploring the use of a tool that creates XMI (UML) files from OWL files. This tool is independent of Protege.

Action item: agree on how much detail we want/need to put into the specifications.

There are different ways to specify cardinality (e.g., making a property functional or asserting that it has maximum cardinality of 1). The OWL2UML converter may be sensitive to which we use. We need to find out.

The minimum annotation should include a textual definition of the class/property/individual. So far we've been placing such definitions in the "comment" annotation.  Alan Rector recommends that we use the <a href='http://code.google.com/p/co-ode-owl-plugins/wiki/AnnotationTemplate'>Annotation Template plugin</a> to make entry of annotations easier.

The Annotation Template is configurable (Preferences / Annotation Template). Proposed fields: Curator, Definition. They should be completed when adding an annotation.

To add Curator and Definition to the template, go to Preferences/Annotation Template then click on the add icon and select from custom annotation URIs list: curator and definition
The URIs are
http://purl.org/net/OCRe/statistics.owl#curator
http://purl.org/net/OCRe/statistics.owl#definitions

In Preferences/Annotations, select statistics:curator and statistics:definition

Besides the Annotation Template, Alan suggested we use the Annotation Search plugin:
Under Preferences/Plugins, choose the two plugins, so they are installed properly and updates are checked.

Alan suggested to add a custom field called devel\_comment to be used for temporary notes that will be removed before the version becomes public.
The Annotation Search plugin allows searching for these comments, so they can be handled.
This helps collaborative efforts in the absence of a true collaborative environment for Protege 4.

The most recent version of OCRe has the relevant old Comment values moved to Definition
The interface allows to add as many comments as needed. A new comment should be added if the topic is completely different from the previous one.

Per recent discussion with Samson, the annotation effort (adding definitions and also domain and range information) will occur on Protege 4.
However, Samson has created also a Protege 3.4-compatible version of OCRe, after verifying that the features of OWL 2 that OCRe is using are not strictly required.

Modifications to classes and properties of OCRe will be made using Protege 4.
New instances/individuals will be instantiated using Protege 3.4