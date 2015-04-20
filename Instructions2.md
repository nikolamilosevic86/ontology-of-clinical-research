# Annotations to study\_protocol.owl from BRIDG 2.2 #
A set of Q from Simona & Answers from Samson:

1. Some text already entered in Comment.
E.g., in class StudyProtocol there is a already a Comment entered.
The definition in the BRIDG file Static Element Report is:
Extends: Document. :  An action plan for a formal investigation to assess the utility, impact, pharmacological, physiological, and psychological effects of a particular treatment, procedure, drug, device, biologic, food product, cosmetic, care plan, or subject characteristic.

The definition is followed by several Notes.

Question: Assuming that I put the BRIDG definition in the Definition field of the Annotation Template, what do I do with the current Comment and also with the Notes?

Answer: Add the BRIDG definition as a "definition" annotation, but make sure that you indicate the source as BRIDG release 2.2. Leave the existing comments or definitions (you can add more than one definitions as annotations. The "Note" entries in BRIDG correspond to "comment" annotations. I suppose we can add them as comments (but again, indicate that they are from BRIDG).

2. The BRIDG superclass is not in OCRe.
E.g., class PlannedArm definition is: Extends: Arm. An arm for which StudySubjects or ExperimentalUnits have not yet been identified.
Class Arm is not defined in OCRe.

Question: How do we handle this case?
Answer: I would add the definitions of both Arm and PlannedArm:

Definition of PlannedArm: An arm for which StudySubjects or ExperimentalUnits have not yet been identified (where "arm" is defined as "A path through the study which describes what activities the subject will be involved in as they pass through the study. For example, a study could have 2 arms named IV-Oral and Oral-IV.  The name IV-Oral reflects a path that passes through IV treatment, then Oral treatment.) BRIDG Release 2.2.

3. Connections and attributes
For each class, BRIDG defines a set of connections and attributes
We currently have object property is operationalized by but we have contains\_the\_activities\_for
We also don't have ScheduledClass and we don't have data property targetAccrualNumber

Question: how much of BRIDG do we need here?
And for the portion of its classes that we use, how consistent do we need to be?

Answer: How much of BRIDG we need will be defined by our use cases. So far we are focusing only on planned entities, and not scheduled or performed things.
I'll just document the classes that we have in the OWL ontology.
We should add the domain and range to the object properties.