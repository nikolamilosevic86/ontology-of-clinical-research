<?xml version="1.0" encoding="UTF-8"?>
<!--
    Created By: Karl Burke karl.burke@jhmi.edu
    $URL$
    $Revision$
    $Date$
    $Author$
    
    This style sheet is used for transforming XML from clinicaltrials.gov which complies with the schema
    http://clinicaltrials.gov/ct2/html/images/info/public.xsd
    to XML complying with the Human Studies Database schema generated from the OCRe ontology, temporarily found at
    http://hsdbxsd.s3-website-us-east-1.amazonaws.com/HSDB_02_21_2012.xsd
    
    Thus far, this transform is compatible with a Basic XSLT processor for XSLT 2.0, as described at
    http://www.w3.org/TR/xslt20/#basic-conformance
    The reference implementation for this, Saxon-HE version 9+, is available as an open source download at
    http://sourceforge.net/projects/saxon/files/
    Once downloaded, the transformation can take place using a simple command line and Java 5+, such as
    java -jar C:\kb\apps\saxon\saxon9he.jar search_result_010512\NCT01503281.xml ct2hsdb.xsl
    
    This stylesheet is not compatible with an XSLT 1.0 processor (due to a few functions which could
    probably easily be worked around).
    
    I will evaluate introducing any schema aware commands which a Basic XSLT processor will signal as an error.
    Since I develop using the Oxygen XML Editor against Saxon-EE, I do have a Schema Aware XSLT processor at a
    reasonable (academic) price, but don't want to introduce unnecessary limitations without valuable return.
    Schema Aware XSLT conformance description
    http://www.w3.org/TR/xslt20/#schema-aware-conformance
    Oxygen Pricing at
    http://www.oxygenxml.com/buy.html
    Saxon-EE Pricing at
    http://saxonica.com/shop/shop.html
    
    @TODO-convert more match-involked templates to xsl:function for text-to-text mappings like study_status, recruitment_status, etc
-->
<!-- The following elements are deliberately not mapped from ct.gov to HSDB
    clinical_study/required_header
    clinical_study/brief_title
    clinical_study/acronym
    clinical_study/source
    clinical_study/oversight_info
    clinical_study/brief_summary
    clinical_study/detailed_description
    clinical_study/why_stopped
    clinical_study/start_date
    clinical_study/end_date
    clinical_study/completion_date
    clinical_study/primary_completion
    clinical_study/phase
    clinical_study/removed_countries
    clinical_study/link
    clinical_study/reference
    clinical_study/results_reference
    clinical_study/verification_data
    clinical_study/firstreceived_date
    clinical_study/firstreceived_results_date
    clinical_study/responsible_party
    clinical_study/keyword
    clinical_study/is_fda_regulated
    clinical_study/is_section_801
    clinical_study/has_expanded_access
    clinical_study/condition_browse
    clinical_study/intervention_browse
    clinical_study/clinical_results
    clinical_study @rank
    clinical_study/id_info/nct_alias
    clinical_study/overall_contact/phone_ext
    clinical_study/overall_contact/middle_name
    clinical_study/overall_contact/degrees
    clinical_study/overall_official/middle_name
    clinical_study/overall_official/degrees
    clinical_study/location/status
    clinical_study/location/contact
    clinical_study/location/contact_backup
    clinical_study/location/investigator
    clinical_study/arm_group/arm_group_type
    clinical_study/arm_group/description
    clinical_study/primary_outcome/safety_issue
    clinical_study/primary_outcome/description
    clinical_study/secondary_outcome/safety_issue
    clinical_study/secondary_outcome/description
    clinical_study/intervention/other_name
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://hsdbxsd.s3-website-us-east-1.amazonaws.com/HSDB_02_21_2012.xsd"
    xmlns:hsdb-ct="http://anyOldStringForNowJustSoFunctionsHaveOwnNamespace"
    exclude-result-prefixes="xs" version="2.0">
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

    <xsl:variable name="globalNctID" select="/clinical_study/id_info/nct_id"/>
    <xsl:variable name="hsdbSchemaLoc">http://hsdbxsd.s3-website-us-east-1.amazonaws.com/HSDB_02_21_2012.xsd</xsl:variable>

    <!-- Generate something for study types which we're not ready to handle yet.
    -->
    <xsl:template match="/clinical_study[lower-case(normalize-space(study_type)) = 'expanded access'] |
                         /clinical_study[lower-case(normalize-space(study_type)) = 'n/a']">
        <xsl:element name="Root">
            <xsl:namespace name="xsi" select="'http://www.w3.org/2001/XMLSchema-instance'"/>
            <xsl:namespace name="sawsdl" select="'http://purl.org/net/OCRe'"/>
            <xsl:attribute name="noNamespaceSchemaLocation" namespace="http://www.w3.org/2001/XMLSchema-instance"><xsl:value-of select="$hsdbSchemaLoc"/></xsl:attribute>

            <xsl:variable name="warnMsg">
                <xsl:value-of select="$globalNctID"/> - WARNING: Mapping from CT.gov to HSDB not available for study_type <xsl:value-of select="study_type"/>
            </xsl:variable>
            <xsl:message>
                <xsl:value-of select="$warnMsg"/>
            </xsl:message>
            <xsl:element name="Study">
                <xsl:comment><xsl:value-of select="$warnMsg"/></xsl:comment>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!--
    Control the generated output using this top-level, imperatively programmed template so the
    output meets the sequence and cardinality specifications of the HSDB schema
    created by Protege from the OCRe ontology.  This is slightly askew because we want to
    create valid output, using as much of the input as we have mapped, rather than directly
    transform the input into something else.
    -->
    <xsl:template match="/clinical_study[lower-case(normalize-space(study_type)) = 'interventional'] |
                         /clinical_study[lower-case(normalize-space(study_type)) = 'observational']">
        <xsl:variable name="ctStudyType" select="lower-case(normalize-space(study_type))"/>
        <xsl:element name="Root">
            <xsl:namespace name="xsi" select="'http://www.w3.org/2001/XMLSchema-instance'"/>
            <xsl:namespace name="sawsdl" select="'http://purl.org/net/OCRe'"/>
            <xsl:attribute name="noNamespaceSchemaLocation" namespace="http://www.w3.org/2001/XMLSchema-instance"><xsl:value-of select="$hsdbSchemaLoc"/></xsl:attribute>

            <xsl:element name="Study">

                <!-- Emit OCRe RecruitmentSite elements from CT.gov location/facility element data -->
                <xsl:apply-templates select="/clinical_study/location/facility"/>

                <!-- Emit OCRe SponsoringRelation elements from CT.gov lead_sponsor and collaborator data elements -->
                <!-- Note: The wildcard selection of all children of sponsors via sponsors/* could cause this transform
                     to emit invalid XML if CT.gov public.xsd were to change sponsors_struct to contain anything other
                     than nodes recognized by the 'match' attribute of a template below i.e. other than
                     lead_sponsor or collaborator
                -->
                <xsl:apply-templates select="/clinical_study/sponsors/*" mode="sponsoring_relation"/>

                <!-- Emit OCRe PlannedSampleSize elements from CT.gov enrollment/@type attribute -->
                <xsl:apply-templates select="/clinical_study/enrollment" mode="planned"/>

                <!-- Emit OCRe DescriptionDate elements from CT.gov lastchanged_date data element -->
                <xsl:apply-templates select="/clinical_study/lastchanged_date"/>

                <!-- Emit OCRe AllocationScheme elements from CT.gov study_design data element -->
                <xsl:apply-templates select="/clinical_study/study_design" mode="allocation_type"/>

                <!-- Emit OCRe ScientificTitle elements from CT.gov official_title data element (or brief_title, if necessary) -->
                <xsl:apply-templates select="/clinical_study/official_title"/>
                <xsl:apply-templates select="/clinical_study/brief_title"/>
                
                <!-- Emit OCRe InterventionAssignmentScheme elements from CT.gov study_design data element -->
                <!-- CT.gov has put Interventions on observational studies in the past, which is not appropriate for an
                     observational studies without further interpretation.  So limit emitting of CT.gov Intervention data
                     to interventional studies pending further analysis
                -->
                <xsl:if test="$ctStudyType = 'interventional'">
                    <xsl:apply-templates select="/clinical_study/study_design" mode="intervention_assignment_scheme"/>
                </xsl:if>

                <!-- Emit OCRe FundingRelation elements from CT.gov agency data elements for the recognized agency_classes -->
                <!-- Note: The wildcard selection of all children of sponsors via sponsors/* could cause this transform
                     to emit invalid XML if CT.gov public.xsd were to change sponsors_struct to contain anything other
                     than nodes recognized by the 'match' attribute of a template below i.e. other than
                     lead_sponsor or collaborator
                -->
                <xsl:apply-templates select="/clinical_study/sponsors/*[agency_class='NIH']" mode="funding_relation"/>
                <xsl:apply-templates select="/clinical_study/sponsors/*[agency_class='U.S. Fed']" mode="funding_relation"/>
                
                <!-- Emit OCRe ActualSampleSize elements from CT.gov enrollment/@type attribute -->
                <xsl:apply-templates select="/clinical_study/enrollment" mode="actual"/>

                <!-- Emit OCRe StudyProtocol elements from CT.gov arm_group data elements -->
                <xsl:element name="StudyProtocol">
                    <xsl:attribute name="type" namespace="http://www.w3.org/2001/XMLSchema-instance">InterventionStudyProtocolType</xsl:attribute>
                    <!-- Emit OCRe OutcomeVariable elements from CT.gov primary_outcome and secondary_outcome data elements -->
                    <xsl:apply-templates select="/clinical_study/primary_outcome"/>
                    <xsl:apply-templates select="/clinical_study/secondary_outcome"/>
                    <!-- CT.gov has put Arms on observational studies in the past, which is not appropriate for an
                         observational studies without further interpretation.  So limit emitting of CT.gov Arm data
                         to interventional studies pending further analysis
                    -->
                    <xsl:if test="$ctStudyType = 'interventional'">
                        <xsl:element name="DividedInto">
                            <xsl:apply-templates select="/clinical_study/arm_group"/>
                        </xsl:element>
                    </xsl:if>
                </xsl:element>
                
                <!-- Emit OCRe StudyDesign elements from CT.gov study_design and study_type data elements -->
                <xsl:apply-templates select="/clinical_study/study_design" mode="study_design"/>
                
                <!-- Emit OCRe PrincipalInvestigator elements from CT.gov overall_official data element -->
                <xsl:apply-templates select="/clinical_study/overall_official"/>
                
                <!-- Emit OCRe RecruitmentStatus element from CT.gov overall_status element data -->
                <xsl:apply-templates select="/clinical_study/overall_status" mode="recruitment_status"/>
                
                <!-- Emit OCRe ContactForPublicQueries elements from CT.gov overall_contact data element -->
                <xsl:apply-templates select="/clinical_study/overall_contact"/>
                
                <!-- Emit OCRe Identifier element from CT.gov id_info element data -->
                <xsl:apply-templates select="/clinical_study/id_info"/>

                <!-- Emit OCRe StudyStatus element from CT.gov overall_status element data -->
                <xsl:apply-templates select="/clinical_study/overall_status" mode="study_status"/>
                
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- developed as xsl:template name="ocreEmitRecruitmentSites" -->
    <xsl:template match="location/facility">
        <xsl:element name="RecruitmentSite">
            <xsl:element name="Name">
                <xsl:value-of select="name"/>
            </xsl:element>
            <xsl:apply-templates select="address"/>
        </xsl:element>
    </xsl:template>

    <!-- developed as xsl:template name="ocreEmitStudyIdentifiers" -->
    <xsl:template match="id_info/nct_id | id_info/org_study_id | id_info/secondary_id">
        <xsl:element name="Identifier">
            <xsl:call-template name="emitOCReInstanceIdentifierType">
                <xsl:with-param name="root">
                    <xsl:value-of select="current()"/>
                </xsl:with-param>
                <xsl:with-param name="name">
                    <xsl:if test="name() = 'nct_id'">ClinicalTrials.gov</xsl:if>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:element>
    </xsl:template>
    
    <!-- developed as xsl:template name="ocreEmitAddress-Postal" -->
    <xsl:template match="address">
        <xsl:if test="city != '' or state != '' or zip != '' or country != ''">
            <xsl:element name="Address">
                <xsl:element name="PostalAddress">
                    <xsl:element name="Zip">
                        <xsl:value-of select="zip"/>
                    </xsl:element>
                    <xsl:element name="Country">
                        <xsl:value-of select="country"/>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="AddressString">
                    <!-- Concatenate together a US-style address as single argument to be presented as AddressString -->
                    <xsl:if test="city != ''">
                        <xsl:value-of select="city"/>
                    </xsl:if>
                    <xsl:if test="city != '' and state != ''">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                    <xsl:if test="state != ''">
                        <xsl:value-of select="state"/>
                    </xsl:if>
                </xsl:element>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <!-- developed as xsl:template name="ocreEmitSponsoringRelation" -->
    <xsl:template match="lead_sponsor | collaborator" mode="sponsoring_relation">
        <xsl:element name="SponsoringRelation">
            <xsl:element name="Actor">
                <xsl:element name="Organization">
                    <xsl:call-template name="emitOCReOrganizationType">
                        <xsl:with-param name="ctName">
                            <xsl:value-of select="agency"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:element>
            </xsl:element>
            <xsl:element name="Priority">
                <xsl:if test="name()='lead_sponsor'">primary</xsl:if>
                <xsl:if test="name()='collaborator'">secondary</xsl:if>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- developed as xsl:template name="ocreEmitDescriptionDate" -->
    <xsl:template match="lastchanged_date">
        <xsl:element name="DescriptionDate">
            <xsl:value-of select="hsdb-ct:ctDateStandardizer(.)"/>
        </xsl:element>
    </xsl:template>

    <!-- developed as xsl:template name="ocreEmitPlannedSampleSize" -->
    <xsl:template match="enrollment" mode="planned">
        <xsl:if test="lower-case(normalize-space(current()/@type)) = 'anticipated'">
            <xsl:element name="PlannedSampleSize">
                <xsl:value-of select="current()"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <!-- developed as xsl:template name="ocreEmitActualSampleSize" -->
    <xsl:template match="enrollment" mode="actual">
        <xsl:if test="lower-case(normalize-space(current()/@type)) = 'actual'">
            <xsl:element name="ActualSampleSize">
                <xsl:value-of select="current()"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <!-- developed as xsl:template name="ocreEmitScientificTitle" -->
    <xsl:template match="official_title">
        <!-- Only use the official_title if it is non-empty -->
        <xsl:if test="current() != ''">
            <xsl:element name="ScientificTitle">
                <xsl:value-of select="current()"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template match="brief_title">
        <!-- Only use the brief_title if the official_title is absent or empty and the brief_title is non-empty -->
        <xsl:if test="(not(/clinical_study/official_title) or /clinical_study/official_title = '') and current() != ''">
            <xsl:element name="ScientificTitle">
                <xsl:value-of select="current()"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    
    <!-- developed as xsl:template name="ocreEmitFundingRelation" -->
    <xsl:template match="lead_sponsor | collaborator" mode="funding_relation">
        <xsl:element name="FundingRelation">
            <xsl:element name="Actor">
                <xsl:element name="Organization">
                    <xsl:call-template name="emitOCReOrganizationType">
                        <xsl:with-param name="ctName">
                            <xsl:value-of select="agency"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- developed as xsl:template name="ocreEmitStudyProtocol" and xsl:template name="ocreEmitArm" -->
    <xsl:template match="arm_group">
        <xsl:for-each select="arm_group_label">
            <xsl:element name="Arm">
                <xsl:apply-templates select="/clinical_study/intervention[arm_group_label=current()]"/>
                <xsl:element name="Name">
                    <xsl:value-of select="current()"/>
                </xsl:element>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>

    <!-- developed as xsl:template name="ocreEmitOutcomeVariables" -->
    <xsl:template match="primary_outcome | secondary_outcome">
        <xsl:element name="OutcomeVariable">
            <xsl:element name="EffectiveTime">
                <xsl:element name="Description">
                    <xsl:value-of select="time_frame"/>
                </xsl:element>
            </xsl:element>
            <xsl:element name="Name">
                <xsl:value-of select="measure"/>
            </xsl:element>
            <xsl:element name="Priority">
                <xsl:if test=" matches(name(),'primary_outcome')">primary</xsl:if>
                <xsl:if test="matches(name(),'secondary_outcome')">secondary</xsl:if>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- developed as xsl:template name="ocreEmitArmContains" -->
    <xsl:template match="intervention">
        <xsl:element name="Contains">
            <xsl:attribute name="type" namespace="http://www.w3.org/2001/XMLSchema-instance">
                <xsl:value-of select="hsdb-ct:ct2HSDBInterventionTypeMap(intervention_type)"/>
            </xsl:attribute>
            <xsl:element name="EffectiveTime">
                <xsl:element name="Description">
                    <xsl:value-of select="description"/>
                </xsl:element>
            </xsl:element>
            <xsl:element name="Name">
                <xsl:value-of select="intervention_name"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- AllocationSchemeType="Restricted randomization" - never from ct.gov clinical_study
                             |"Stratified randomization" - never from ct.gov clinical_study
                             |"Minimization"             - never from ct.gov clinical_study
                             |"Simple randomization"     - never from ct.gov clinical_study
                             |"Block randomization"      - never from ct.gov clinical_study
                             |"Non-random allocation"    - when ct.gov study_design has Allocation: Non-Randomized
                             |"Random allocation"        - when ct.gov study_design has Allocation: Randomized
    -->
    <!-- developed as xsl:template name="ocreEmitAllocationType" -->
    <xsl:template match="study_design" mode="allocation_type">
        <xsl:variable name="ctStudyDesign" select="lower-case(normalize-space(current()))"/>
        <xsl:variable name="ctStudyType" select="lower-case(normalize-space(/clinical_study/study_type))"/>
        <!-- Assume the study_design xsd:string only uses the comma to separate attributes, not in attribute values. -->
        <!-- Not evaluating a node set, so combine for-each and call-template rather than using apply-templates. -->
        <xsl:for-each select="tokenize($ctStudyDesign,',')">
            <xsl:variable name="ctStudyDesignKeyValue" select="tokenize(.,':')"/>
            <xsl:choose>
                <xsl:when test="normalize-space($ctStudyDesignKeyValue[1]) = 'allocation'">
                    <xsl:variable name="ctAllocationValue" select="normalize-space($ctStudyDesignKeyValue[2])"/>
                    <xsl:element name="AllocationType">
                        <xsl:choose>
                            <xsl:when test="$ctStudyType = lower-case('Interventional') and $ctAllocationValue = lower-case('Randomized')">Random allocation</xsl:when>
                            <xsl:when test="$ctStudyType = lower-case('Interventional') and $ctAllocationValue = lower-case('Non-Randomized')">Non-random allocation</xsl:when>
                            <xsl:otherwise>
                                <xsl:variable name="errMsg">
                                    <xsl:value-of select="$globalNctID"/> - ERROR: UNDETERMINED for CT.gov Allocation:<xsl:value-of select="$ctAllocationValue"/> for study_type <xsl:value-of select="$ctStudyType"/>
                                </xsl:variable>
                                <xsl:message>
                                    <xsl:value-of select="$errMsg"/>
                                </xsl:message>
                                <xsl:value-of select="$errMsg"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <!-- InterventionAssignmentScheme="Factorial"      - when ct.gov study_design has Intervention Model: Factorial Assignment
                                     |"Single-factor" - never from ct.gov clinical_study
    -->
    <xsl:template match="study_design" mode="intervention_assignment_scheme">
        <xsl:variable name="ctStudyDesign" select="lower-case(normalize-space(current()))"/>
        
        <!-- Assume the study_design xsd:string only uses the comma to separate attributes, not within attribute values. -->
        <!-- Assume the CT.gov study_design xsd:string will contain only one of {Observational Model, Intervention Model, Time Perspective} -->
        <!-- Not evaluating a node set, so combine for-each and call-template rather than using apply-templates. -->
        <xsl:if test="contains($ctStudyDesign,lower-case('Intervention Model'))">
            <xsl:for-each select="tokenize($ctStudyDesign,',')">
                <xsl:variable name="ctStudyDesignKeyValue" select="tokenize(.,':')"/>
                <xsl:variable name="ctStudyDesignKey" select="normalize-space($ctStudyDesignKeyValue[1])"/>
                <xsl:variable name="ctStudyDesignValue" select="normalize-space($ctStudyDesignKeyValue[2])"/>
                <xsl:if test="$ctStudyDesignKey = lower-case('Intervention Model') and $ctStudyDesignValue = lower-case('Factorial Assignment')">
                    <xsl:element name="InterventionAssignmentScheme">Factorial</xsl:element>
                </xsl:if>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
        
    <!-- StudyDesignType=no StudyDesign emitted          - when study_type is Expanded Access
                        |"Case-crossover study design"   - when ct.gov study_design has Observational Model: Case-Crossover
                        |"Parallel group study design"   - when ct.gov study_design has Intervention Model: Parallel Assignment
                        |"Parallel group study design"   - when ct.gov study_design has Intervention Model: Factorial Assignment
                        |"Crossover study design"        - when ct.gov study_design has Intervention Model: Crossover Assignment
                        |"Single group study design"     - when ct.gov study_design has Intervention Model: Single Group Assignment
                        |"Cohort study design"           - when ct.gov study_design has Observational Model: Cohort
                        |"Case-control study design"     - when ct.gov study_design has Observational Model: Case Control
                        |"Cross-sectional study design"  - when ct.gov study_design has Time Perspective: Cross-Sectional
                        |"N-of-1 crossover study design" - never from ct.gov clinical_study
                        |"Quantitative study design"     - never from ct.gov clinical_study
                        |"Qualitative study design"      - never from ct.gov clinical_study
                        |"Observational study design"    - when none of above, and ct.gov study_type is Observational
                        |"Interventional study design"   - when none of above, and ct.gov study_type is Interventional
    -->
    <!-- developed as xsl:template name="ocreEmitStudyDesign" -->
    <xsl:template match="study_design" mode="study_design">
        <xsl:variable name="ctStudyDesign" select="lower-case(normalize-space(current()))"/>
        <xsl:variable name="ctStudyTypeNode" select="/clinical_study/study_type"/>

        <!-- Assume the study_design xsd:string only uses the comma to separate attributes, not within attribute values. -->
        <!-- Assume the CT.gov study_design xsd:string will contain only one of {Observational Model, Intervention Model, Time Perspective} -->
        <!-- Not evaluating a node set, so combine for-each and call-template rather than using apply-templates. -->
        <xsl:element name="StudyDesign">
            <xsl:choose>
                <xsl:when test="contains($ctStudyDesign,lower-case('Observational Model')) or
                                contains($ctStudyDesign,lower-case('Intervention Model')) or
                                contains($ctStudyDesign,lower-case('Time Perspective'))">
                    <xsl:for-each select="tokenize($ctStudyDesign,',')">
                        <xsl:variable name="ctStudyDesignKeyValue" select="tokenize(.,':')"/>
                        <xsl:variable name="ctStudyDesignKey" select="normalize-space($ctStudyDesignKeyValue[1])"/>
                        <xsl:variable name="ctStudyDesignValue" select="normalize-space($ctStudyDesignKeyValue[2])"/>
                        <xsl:choose>
                            <xsl:when test="$ctStudyDesignKey = lower-case('Observational Model')">
                                <xsl:choose>
                                    <xsl:when test="$ctStudyDesignValue = lower-case('Case-Crossover')">Case-crossover study design</xsl:when>
                                    <xsl:when test="$ctStudyDesignValue = lower-case('Cohort')">Cohort study design</xsl:when>
                                    <xsl:when test="$ctStudyDesignValue = lower-case('Case Control')">Case-control study design</xsl:when>
                                    <xsl:when test="$ctStudyDesignValue = lower-case('Ecologic or Community')">
                                        <xsl:apply-templates select="$ctStudyTypeNode"/>
                                    </xsl:when>
                                    <xsl:when test="$ctStudyDesignValue = lower-case('Family-based')">
                                        <xsl:apply-templates select="$ctStudyTypeNode"/>
                                    </xsl:when>
                                    <xsl:when test="$ctStudyDesignValue = lower-case('other')">
                                        <xsl:apply-templates select="$ctStudyTypeNode"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:variable name="warnMsg">
                                            <xsl:value-of select="$globalNctID"/> - WARNING: UNDETERMINED for CT.gov study_design characteristic <xsl:value-of select="$ctStudyDesignKey"/>:<xsl:value-of select="$ctStudyDesignValue"/>
                                        </xsl:variable>
                                        <xsl:message>
                                            <xsl:value-of select="$warnMsg"/>
                                        </xsl:message>
                                        <!-- Since warnMsg posted about unrecognized study_design, just use study_type to create value -->
                                        <xsl:apply-templates select="$ctStudyTypeNode"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="$ctStudyDesignKey = lower-case('Intervention Model')">
                                <xsl:choose>
                                    <xsl:when test="$ctStudyDesignValue = lower-case('Parallel Assignment')">Parallel group study design</xsl:when>
                                    <xsl:when test="$ctStudyDesignValue = lower-case('Factorial Assignment')">Parallel group study design</xsl:when>
                                    <xsl:when test="$ctStudyDesignValue = lower-case('Crossover Assignment')">Crossover study design</xsl:when>
                                    <xsl:when test="$ctStudyDesignValue = lower-case('Single Group Assignment')">Single group study design</xsl:when>
                                    <xsl:otherwise>
                                        <xsl:variable name="warnMsg">
                                            <xsl:value-of select="$globalNctID"/> - WARNING: UNDETERMINED for CT.gov study_design characteristic <xsl:value-of select="$ctStudyDesignKey"/>:<xsl:value-of select="$ctStudyDesignValue"/>
                                        </xsl:variable>
                                        <xsl:message>
                                            <xsl:value-of select="$warnMsg"/>
                                        </xsl:message>
                                        <!-- Since warnMsg posted about unrecognized study_design, just use study_type to create value -->
                                        <xsl:apply-templates select="$ctStudyTypeNode"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="$ctStudyDesignKey = lower-case('Time Perspective')">
                                <xsl:choose>
                                    <xsl:when test="$ctStudyDesignValue = lower-case('Cross-Sectional')">Cross-sectional study design</xsl:when>
                                    <xsl:otherwise>
                                        <!-- Don't put out a warning for values of Time Perspective we recognize from
                                                 http://prsinfo.clinicaltrials.gov/definitions.html but do not choose to map to a distinct HSDB value 
                                            -->
                                        <xsl:if test="$ctStudyDesignValue != lower-case('Prospective') and $ctStudyDesignValue != lower-case('Retrospective') and $ctStudyDesignValue != lower-case('Retrospective/Prospective') and $ctStudyDesignValue != lower-case('Other')">
                                            <xsl:variable name="warnMsg">
                                                <xsl:value-of select="$globalNctID"/> - WARNING: UNDETERMINED for CT.gov study_design characteristic <xsl:value-of select="$ctStudyDesignKey"/>:<xsl:value-of select="$ctStudyDesignValue"/>
                                            </xsl:variable>
                                            <xsl:message>
                                                <xsl:value-of select="$warnMsg"/>
                                            </xsl:message>
                                        </xsl:if>
                                        <!-- Since warnMsg posted about unrecognized study_design, just use study_type to create value -->
                                        <xsl:apply-templates select="$ctStudyTypeNode"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="/clinical_study/study_type"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>

    <!-- developed as xsl:template name="ocreEmitStudyDesignFromStudyType" -->
    <xsl:template match="study_type">
        <xsl:variable name="ctStudyType" select="lower-case(normalize-space(current()))"/>
        <xsl:choose>
            <xsl:when test="$ctStudyType = lower-case('Interventional')">Interventional study design</xsl:when>
            <xsl:when test="$ctStudyType = lower-case('Observational')">Observational study design</xsl:when>
            <xsl:otherwise>
                <xsl:variable name="errMsg">
                    <xsl:value-of select="$globalNctID"/> - ERROR: UNDETERMINED for CT.gov study_type = <xsl:value-of select="$ctStudyType"/>
                </xsl:variable>
                <xsl:message>
                    <xsl:value-of select="$errMsg"/>
                </xsl:message>
                <xsl:value-of select="$errMsg"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- developed as xsl:template name="ocreEmitPrincipalInvestigator" -->
    <xsl:template match="overall_official">
        <xsl:element name="PrincipalInvestigator">
            <xsl:call-template name="emitOCRePersonType">
                <xsl:with-param name="ctFirstName">
                    <xsl:value-of select="first_name"/>
                </xsl:with-param>
                <xsl:with-param name="ctLastName">
                    <xsl:value-of select="last_name"/>
                </xsl:with-param>
                <xsl:with-param name="ctAffiliation">
                    <xsl:value-of select="affiliation"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:element>
    </xsl:template>

    <!-- RecruitmentStatus="Recruitment not yet started" - when ct.gov overall_status is 'not yet recruiting'
                          |"Recruitment active"          - when ct.gov overall_status is 'recruiting'
                          |"Recruitment suspended"       - when ct.gov overall_status is 'suspended'
                          |"Recruitment will not start"  - when ct.gov overall_status is 'withdrawn'
                          |"Recruitment terminated"      - when ct.gov overall_status is 'terminated'
                          |"Recruitment completed"       - never from ct.gov clinical_study
    -->
    <!-- developed as xsl:template name="ocreEmitRecruitmentStatus" -->
    <xsl:template match="overall_status" mode="recruitment_status">
        <xsl:variable name="ctOverallStatus" select="lower-case(normalize-space(current()))"/>
        <!-- Do not emit the tag for certain recognized values of overall_status -->
        <xsl:if test="$ctOverallStatus != 'enrolling by invitation' and $ctOverallStatus != 'completed'">
            <xsl:element name="RecruitmentStatus">
                <xsl:choose>
                    <xsl:when test="$ctOverallStatus = 'terminated'">Recruitment terminated</xsl:when>
                    <xsl:when test="$ctOverallStatus = 'suspended'">Recruitment suspended</xsl:when>
                    <xsl:when test="$ctOverallStatus = 'recruiting'">Recruitment active</xsl:when>
                    <xsl:when test="$ctOverallStatus = 'withdrawn'">Recruitment will not start</xsl:when>
                    <xsl:when test="$ctOverallStatus = 'not yet recruiting'">Recruitment not yet started</xsl:when>
                    <xsl:when test="$ctOverallStatus = 'active, not recruiting'">Recruitment not active</xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="errMsg">
                            <xsl:value-of select="$globalNctID"/> - ERROR: UNDETERMINED RecruitmentStatus for CT.gov overall_status = <xsl:value-of select="$ctOverallStatus"/>
                        </xsl:variable>
                        <xsl:message>
                            <xsl:value-of select="$errMsg"/>
                        </xsl:message>
                        <xsl:value-of select="$errMsg"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <!-- StudyStatus="Study completed"  - when ct.gov overall_status is 'completed'
                    |"Study withdrawn"  - when ct.gov overall_status is 'withdrawn'
                    |"Study active"     - when ct.gov overall_status is 'recruiting' or 'active, not recruiting'
                    |"Study suspended"  - never from ct.gov clinical_study
                    |"Study terminated" - never from ct.gov clinical_study
                    |"Study planned"    - never from ct.gov clinical_study
    -->
    <!-- developed as xsl:template name="ocreEmitStudyStatus" -->
    <xsl:template match="overall_status" mode="study_status">
        <xsl:variable name="ctOverallStatus" select="lower-case(normalize-space(current()))"/>
        <!-- Do not emit the tag for certain recognized values of overall_status -->
        <xsl:if test="$ctOverallStatus != 'terminated' and $ctOverallStatus != 'enrolling by invitation' and $ctOverallStatus != 'suspended' and $ctOverallStatus != 'not yet recruiting'">
            <xsl:element name="StudyStatus">
                <xsl:choose>
                    <xsl:when test="$ctOverallStatus = 'completed'">Study completed</xsl:when>
                    <xsl:when test="$ctOverallStatus = 'recruiting'">Study active</xsl:when>
                    <xsl:when test="$ctOverallStatus = 'withdrawn'">Study withdrawn</xsl:when>
                    <xsl:when test="$ctOverallStatus = 'active, not recruiting'">Study active</xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="errMsg">
                            <xsl:value-of select="$globalNctID"/> - ERROR: UNDETERMINED StudyStatus for CT.gov overall_status = <xsl:value-of select="$ctOverallStatus"/>
                        </xsl:variable>
                        <xsl:message>
                            <xsl:value-of select="$errMsg"/>
                        </xsl:message>
                        <xsl:value-of select="$errMsg"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <!-- developed as xsl:template name="ocreEmitContactForPublicQueries" -->
    <xsl:template match="overall_contact">
        <xsl:element name="ContactForPublicQueries">
            <xsl:element name="Person">
                <xsl:call-template name="emitOCRePersonType">
                    <xsl:with-param name="ctFirstName">
                        <xsl:value-of select="first_name"/>
                    </xsl:with-param>
                    <xsl:with-param name="ctLastName">
                        <xsl:value-of select="last_name"/>
                    </xsl:with-param>
                    <xsl:with-param name="ctEmail">
                        <xsl:value-of select="email"/>
                    </xsl:with-param>
                    <xsl:with-param name="ctPhone">
                        <xsl:value-of select="phone"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <!-- Emit the markup for the complexType PersonType in the HSDB XSD -->
    <xsl:template name="emitOCRePersonType">
        <xsl:param name="ctFirstName"/>
        <xsl:param name="ctLastName"/>
        <xsl:param name="ctAffiliation"/>
        <xsl:param name="ctEmail"/>
        <xsl:param name="ctPhone"/>
        <xsl:param name="ctPhoneExt"/>
        
        <xsl:if test="$ctAffiliation != ''">
            <xsl:element name="MemberOf">
                <xsl:call-template name="emitOCReOrganizationType">
                    <xsl:with-param name="ctName">
                        <xsl:value-of select="affiliation"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:element>
        </xsl:if>
        <xsl:if test="$ctFirstName != ''">
            <xsl:element name="FirstName">
                <xsl:value-of select="$ctFirstName"/>
            </xsl:element>
        </xsl:if>
        <xsl:if test="$ctEmail != ''">
            <xsl:element name="Address">
                <xsl:element name="TelecommunicationAddress">
                    <xsl:call-template name="emitOCReTelecommunicationAddressType">
                        <xsl:with-param name="schemeType">mailto</xsl:with-param>
                    </xsl:call-template>
                </xsl:element>
                <xsl:element name="AddressString">
                    <xsl:value-of select="$ctEmail"/>
                </xsl:element>
            </xsl:element>
        </xsl:if>
        <xsl:if test="$ctPhone != ''">
            <xsl:element name="Address">
                <xsl:element name="TelecommunicationAddress">
                    <xsl:call-template name="emitOCReTelecommunicationAddressType">
                        <xsl:with-param name="schemeType">tel</xsl:with-param>
                    </xsl:call-template>
                </xsl:element>
                <xsl:element name="AddressString">
                    <xsl:value-of select="$ctPhone"/>
                </xsl:element>
            </xsl:element>
        </xsl:if>
        
        <xsl:if test="$ctLastName != ''">
            <xsl:element name="LastName">
                <xsl:value-of select="$ctLastName"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    
    <!-- Emit the markup for the complexType OrganizationType in the HSDB XSD -->
    <xsl:template name="emitOCReOrganizationType">
        <xsl:param name="ctName"/>
        
        <xsl:element name="Name">
            <xsl:value-of select="$ctName"/>
        </xsl:element>
    </xsl:template>

    <!-- Emit the markup for the complexType InstanceIdentifierType in the HSDB XSD -->
    <xsl:template name="emitOCReInstanceIdentifierType">
        <xsl:param name="root"/>
        <xsl:param name="name"/>
        <xsl:if test="$root != '' or $name != ''">
            <xsl:if test="$root != ''">
                <xsl:element name="Root">
                    <xsl:value-of select="$root"/>
                </xsl:element>
            </xsl:if>
            <xsl:if test="$name != ''">
                <xsl:element name="IdentifierName">
                    <xsl:value-of select="$name"/>
                </xsl:element>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    
    <!-- Emit the markup for the complexType TelecommunicationAddressType in the HSDB XSD -->
    <xsl:template name="emitOCReTelecommunicationAddressType">
        <xsl:param name="schemeType"/>
        
        <xsl:element name="Scheme">
            <xsl:value-of select="$schemeType"/>
        </xsl:element>
    </xsl:template>
        
    <!--
        The date_struct at http://clinicaltrials.gov/ct2/html/images/info/public.xsd just
        specifies an xs:string, where the HSDB XSD specifies an xsd:date (ISI 8601).  This template
        will encapsulate logic for an representation encountered in CT.gov, including
        those with resolution of less than a calendar day e.g. "January 2012"
        
        Assumptions:
            1. When split on white space, will end up with two or three strings
            2. The first token is the month and the last token is the year
            3. If there are three tokens, the middle one indicates the day of the month
            4. The month is represented with the full US English word
            5. Non-alphanumeric characters, such as comma or period, can be removed from strings
            6. There are no two digit representations of the year in CT.gov
    -->
    <xsl:function name="hsdb-ct:ctDateStandardizer" as="xs:date">
        <xsl:param name="ctDateString"/>
        <xsl:variable name="ctDateTokens" select="tokenize($ctDateString,'\s+')"/>
        <xsl:variable name="yearNum">
            <xsl:if test="count($ctDateTokens) = 2">
                <xsl:value-of select="$ctDateTokens[2]"/>
            </xsl:if>
            <xsl:if test="count($ctDateTokens) = 3">
                <xsl:value-of select="$ctDateTokens[3]"/>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="monthNum">
            <xsl:value-of select="hsdb-ct:enUsMonthNumber($ctDateTokens[1])"/>
        </xsl:variable>
        <xsl:variable name="dayNum">
            <xsl:if test="count($ctDateTokens) = 2">01</xsl:if>
            <xsl:if test="count($ctDateTokens) = 3">
                <!-- remove the comma after the day of month for dates in the form
                     December 7, 2012, and prepend a zero if day of month is only one digit -->
                <xsl:if test="number(replace($ctDateTokens[2],'[,]','')) &lt; 10">0</xsl:if>
                <xsl:value-of select="replace($ctDateTokens[2],'[,]','')"/>
            </xsl:if>
        </xsl:variable>
        <xsl:value-of select="concat($yearNum,'-',$monthNum,'-',$dayNum)"/>
    </xsl:function>

    <!-- Map US English months encountered in CT.gov xsd:string representation of dates to
         a two digit month which can be a component of an xsd:date in HSDB
    -->
    <xsl:function name="hsdb-ct:enUsMonthNumber" as="xs:string">
        <xsl:param name="enUsMonthString"/>
        <xsl:choose>
            <xsl:when test="lower-case($enUsMonthString) = 'january'">01</xsl:when>
            <xsl:when test="lower-case($enUsMonthString) = 'february'">02</xsl:when>
            <xsl:when test="lower-case($enUsMonthString) = 'march'">03</xsl:when>
            <xsl:when test="lower-case($enUsMonthString) = 'april'">04</xsl:when>
            <xsl:when test="lower-case($enUsMonthString) = 'may'">05</xsl:when>
            <xsl:when test="lower-case($enUsMonthString) = 'june'">06</xsl:when>
            <xsl:when test="lower-case($enUsMonthString) = 'july'">07</xsl:when>
            <xsl:when test="lower-case($enUsMonthString) = 'august'">08</xsl:when>
            <xsl:when test="lower-case($enUsMonthString) = 'september'">09</xsl:when>
            <xsl:when test="lower-case($enUsMonthString) = 'october'">10</xsl:when>
            <xsl:when test="lower-case($enUsMonthString) = 'november'">11</xsl:when>
            <xsl:when test="lower-case($enUsMonthString) = 'december'">12</xsl:when>
            <xsl:otherwise>
                <xsl:variable name="errMsg"><xsl:value-of select="$globalNctID"/> - ERROR: Unexpected date format for CT.gov string '<xsl:value-of select="$enUsMonthString"/>'</xsl:variable>
                <xsl:message>
                    <xsl:value-of select="$errMsg"/>
                </xsl:message>
                <xsl:value-of select="$errMsg"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- Map values encountered in CT.gov xsd:string for intervention_type to
         the corresponding HSDB PlannedActivityType extension for the type
         attribute of a Study/StudyProtocol/DividedInto/Arm/Contains element
    -->
    <xsl:function name="hsdb-ct:ct2HSDBInterventionTypeMap" as="xs:string">
        <xsl:param name="ctInterventionType"/>
        <xsl:choose>
            <!-- this when/otherwise can be refactored if we truly do not wish to be alerted to new ct.gov intervention_type values -->
            <xsl:when test="lower-case($ctInterventionType) = 'drug'">PlannedSubstanceAdministrationType</xsl:when>
            <xsl:when test="lower-case($ctInterventionType) = 'dietary supplement'">PlannedSubstanceAdministrationType</xsl:when>
            <xsl:when test="lower-case($ctInterventionType) = 'biological/vaccine'">PlannedSubstanceAdministrationType</xsl:when>
            <xsl:when test="lower-case($ctInterventionType) = 'biological'">PlannedSubstanceAdministrationType</xsl:when>
            <xsl:when test="lower-case($ctInterventionType) = 'vaccine'">PlannedSubstanceAdministrationType</xsl:when>
            <xsl:when test="lower-case($ctInterventionType) = 'device'">PlannedProcedureType</xsl:when>
            <xsl:when test="lower-case($ctInterventionType) = 'genetic'">PlannedProcedureType</xsl:when>
            <xsl:when test="lower-case($ctInterventionType) = 'behavioral'">PlannedProcedureType</xsl:when>
            <xsl:when test="lower-case($ctInterventionType) = 'radiation'">PlannedProcedureType</xsl:when>
            <xsl:when test="lower-case($ctInterventionType) = 'procedure/surgery'">PlannedProcedureType</xsl:when>
            <xsl:when test="lower-case($ctInterventionType) = 'procedure'">PlannedProcedureType</xsl:when>
            <xsl:when test="lower-case($ctInterventionType) = 'surgery'">PlannedProcedureType</xsl:when>
            <xsl:when test="lower-case($ctInterventionType) = 'other'">PlannedProcedureType</xsl:when>
            <xsl:otherwise>
                <xsl:variable name="errMsg">
                    <xsl:value-of select="$globalNctID"/> - ERROR: UNDETERMINED for CT.gov intervention_type = <xsl:value-of select="$ctInterventionType"/></xsl:variable>
                <xsl:message>
                    <xsl:value-of select="$errMsg"/>
                </xsl:message>
                <xsl:value-of select="$errMsg"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>
