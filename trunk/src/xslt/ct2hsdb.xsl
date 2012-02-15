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
    http://hsdbweb.s3.amazonaws.com/HSDB_xsd_V12.xsd
    
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
    
    @TODO-refactor for cut & paste re-use, XSLT conventions
    @TODO-refactor for typical declarative XSLT style once ct.gov to ocre mappings complete
    @TODO-document each template
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
    xmlns:xsi="http://hsdbweb.s3.amazonaws.com/HSDB_xsd_V12.xsd"
    xmlns:hsdb-ct="http://anyOldStringForNowJustSoFunctionsHaveOwnNamespace"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:output method="xml" encoding="UTF-8" indent="yes" />

    <xsl:variable name="globalNctID" select="/clinical_study/id_info/nct_id"/>

    <!-- Generate something for study types which we're not ready to handle yet.
    -->
    <xsl:template match="/clinical_study[lower-case(normalize-space(study_type)) = 'expanded access'] |
                         /clinical_study[lower-case(normalize-space(study_type)) = 'n/a']">
        <xsl:element name="Root">
            <xsl:namespace name="xsi" select="'http://www.w3.org/2001/XMLSchema-instance'"/>
            <xsl:namespace name="sawsdl" select="'http://purl.org/net/OCRe'"/>
            <xsl:attribute name="noNamespaceSchemaLocation" namespace="http://www.w3.org/2001/XMLSchema-instance">http://hsdbweb.s3.amazonaws.com/HSDB_xsd_V12.xsd</xsl:attribute>
            
            <xsl:variable name="warnMsg"><xsl:value-of select="$globalNctID"/> - WARNING: Mapping from CT.gov to HSDB not available for study_type <xsl:value-of select="study_type"/></xsl:variable>
            <xsl:message><xsl:value-of select="$warnMsg"/></xsl:message>
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
        <xsl:element name="Root">
            <xsl:namespace name="xsi" select="'http://www.w3.org/2001/XMLSchema-instance'"/>
            <xsl:namespace name="sawsdl" select="'http://purl.org/net/OCRe'"/>
            <xsl:attribute name="noNamespaceSchemaLocation" namespace="http://www.w3.org/2001/XMLSchema-instance">http://hsdbweb.s3.amazonaws.com/HSDB_xsd_V12.xsd</xsl:attribute>
            
            <xsl:element name="Study">
                
                <xsl:call-template name="ocreEmitRecruitmentSites"/>
                <xsl:call-template name="ocreEmitSponsoringRelation"/>
                <xsl:call-template name="ocreEmitPlannedSampleSize"/>
                <xsl:call-template name="ocreEmitDescriptionDate"/>
                <xsl:call-template name="ocreEmitAllocationType"/>
                <xsl:call-template name="ocreEmitScientificTitle"/>
                <xsl:call-template name="ocreEmitIRB"/>
                <xsl:call-template name="ocreEmitComparativeIntent"/>
                <xsl:call-template name="ocreEmitFundingRelation"/>
                <xsl:call-template name="ocreEmitActualSampleSize"/>
                <xsl:call-template name="ocreEmitStudyProtocol"/>
                <xsl:call-template name="ocreEmitStudyDesign"/>
                <xsl:call-template name="ocreEmitPrincipalInvestigator"/>
                <xsl:call-template name="ocreEmitRecruitmentStatus"/>
                <xsl:call-template name="ocreEmitContactForPublicQueries"/>
                <xsl:call-template name="ocreEmitStudyIdentifiers"/>                
                <xsl:call-template name="ocreEmitStudyStatus"/>
                
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template name="ocreEmitStudyIdentifiers">
        <xsl:call-template name="ocreEmitIdentifier">
            <xsl:with-param name="root"><xsl:value-of select="id_info/nct_id"/></xsl:with-param>
            <xsl:with-param name="name">ClinicalTrials.gov</xsl:with-param>
        </xsl:call-template>  
        <xsl:call-template name="ocreEmitIdentifier">
            <xsl:with-param name="root"><xsl:value-of select="id_info/org_study_id"/></xsl:with-param>
        </xsl:call-template>  
        <xsl:call-template name="ocreEmitIdentifier">
            <xsl:with-param name="root"><xsl:value-of select="id_info/secondary_id"/></xsl:with-param>
        </xsl:call-template>  
    </xsl:template>
    
    <xsl:template name="ocreEmitIdentifier">
        <xsl:param name="root"/>
        <xsl:param name="name"/>
        <xsl:if test="$root != '' or $name != ''">
            <xsl:element name="Identifier">
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
            </xsl:element>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="ocreEmitRecruitmentSites">
        <xsl:for-each select="location/facility">
            <xsl:element name="RecruitmentSite">
                <xsl:element name="Name"><xsl:value-of select="name"/></xsl:element>
                <xsl:call-template name="ocreEmitAddress-Postal">
                    <xsl:with-param name="ctCity"><xsl:value-of select="address/city"/></xsl:with-param>
                    <xsl:with-param name="ctState"><xsl:value-of select="address/state"/></xsl:with-param>
                    <xsl:with-param name="ctZip"><xsl:value-of select="address/zip"/></xsl:with-param>
                    <xsl:with-param name="ctCountry"><xsl:value-of select="address/country"/></xsl:with-param>
                </xsl:call-template>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>

    <!-- @TODO: Once mapping complete and trying declarative structure to this transform, consolidate
        all the <Address> emitting rules to one using match/mode.
        (ocreEmitAddress-Postal, ocreEmitAddress-Email, ocreEmitAddress-Telephone)
    -->
    <xsl:template name="ocreEmitAddress-Postal">
        <xsl:param name="ctStreet"/>
        <xsl:param name="ctCity"/>
        <xsl:param name="ctState"/>
        <xsl:param name="ctZip"/>
        <xsl:param name="ctCountry"/>
        <xsl:if test="$ctStreet != '' or $ctCity != '' or $ctState != '' or $ctZip != '' or $ctCountry != ''">
            <xsl:element name="Address">
                <xsl:element name="PostalAddress">
                    <xsl:element name="Zip"><xsl:value-of select="$ctZip"/></xsl:element>
                    <xsl:element name="Country"><xsl:value-of select="$ctCountry"/></xsl:element>
                </xsl:element>
                <xsl:call-template name="ocreEmitAddressString">
                    <xsl:with-param name="val">
                        <!-- Concatenate together a US-style address as single argument to be presented as AddressString -->
                        <xsl:if test="$ctStreet != ''">
                            <xsl:value-of select="$ctStreet"/><xsl:text> </xsl:text>
                        </xsl:if>
                        <xsl:if test="$ctCity != ''">
                            <xsl:value-of select="$ctCity"/>
                        </xsl:if>
                        <xsl:if test="$ctCity != '' and $ctState != ''">
                            <xsl:text>, </xsl:text>
                        </xsl:if>
                        <xsl:if test="$ctState != ''">
                            <xsl:value-of select="$ctState"/>
                        </xsl:if>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="ocreEmitAddress-Email">
        <xsl:param name="ctEmail"/>
        <xsl:if test="$ctEmail != ''">
            <xsl:element name="Address">
                <xsl:call-template name="ocreEmitTelecommunicationsAddress">
                    <xsl:with-param name="schemeType">mailto</xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="ocreEmitAddressString">
                    <xsl:with-param name="val"><xsl:value-of select="$ctEmail"/></xsl:with-param>
                </xsl:call-template>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="ocreEmitAddress-Telephone">
        <xsl:param name="ctPhone"/>
        <xsl:param name="ctPhoneExt"/>
        <xsl:if test="$ctPhone != ''">
            <xsl:element name="Address">
                <xsl:call-template name="ocreEmitTelecommunicationsAddress">
                    <xsl:with-param name="schemeType">tel</xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="ocreEmitAddressString">
                    <xsl:with-param name="val">
                        <xsl:value-of select="$ctPhone"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="ocreEmitAddressString">
        <xsl:param name="val"/>
        <xsl:element name="AddressString"><xsl:value-of select="$val"/></xsl:element>
    </xsl:template>

    <xsl:template name="ocreEmitTelecommunicationsAddress">
        <xsl:param name="schemeType"/>
        <xsl:element name="TelecommunicationAddress">
            <xsl:element name="Scheme">
                <xsl:value-of select="$schemeType"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>    
    
    <xsl:template name="ocreEmitSponsoringRelation">
        <xsl:for-each select="//clinical_study/sponsors/*">
            <xsl:element name="SponsoringRelation">
                <xsl:element name="Actor">
                    <xsl:element name="Organization">
                        <xsl:call-template name="ocreEmitOrganization">
                            <xsl:with-param name="ctName">
                                <xsl:value-of select="agency"/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="Priority">
                    <xsl:if test="name(.)='lead_sponsor'">primary</xsl:if>
                    <xsl:if test="name(.)='collaborator'">secondary</xsl:if>
                </xsl:element>                    
            </xsl:element>        
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="ocreEmitDescriptionDate">
        <xsl:element name="DescriptionDate"><xsl:value-of select="hsdb-ct:ctDateStandardizer(lastchanged_date)"/>
        </xsl:element>
    </xsl:template>

    <xsl:template name="ocreEmitPlannedSampleSize">
        <xsl:variable name="ctEnrollment" select="enrollment"/>
        <xsl:variable name="ctEnrollmentType" select="lower-case(normalize-space(enrollment/@type))"/>
        <xsl:if test="$ctEnrollmentType = 'anticipated'">
            <xsl:element name="PlannedSampleSize"><xsl:value-of select="enrollment"/></xsl:element>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="ocreEmitActualSampleSize">
        <xsl:variable name="ctEnrollment" select="enrollment"/>
        <xsl:variable name="ctEnrollmentType" select="lower-case(normalize-space(enrollment/@type))"/>
        <xsl:if test="$ctEnrollmentType = 'actual'">
            <xsl:element name="ActualSampleSize"><xsl:value-of select="enrollment"/></xsl:element>
        </xsl:if>
    </xsl:template>
    
    <!-- AllocationSchemeType="Restricted randomization" - never from ct.gov clinical_study
                             |"Stratified randomization" - never from ct.gov clinical_study
                             |"Minimization"             - never from ct.gov clinical_study
                             |"Simple randomization"     - never from ct.gov clinical_study
                             |"Block randomization"      - never from ct.gov clinical_study
                             |"Non-random allocation"    - when ct.gov study_design has Allocation: Non-Randomized
                             |"Random allocation"        - when ct.gov study_design has Allocation: Randomized
    -->
    <xsl:template name="ocreEmitAllocationType">
        <xsl:variable name="ctStudyDesign" select="lower-case(normalize-space(study_design))"/>
        <!-- Assume the study_design xsd:string only uses the comma to separate attributes, not in attribute values. -->
        <!-- Not evaluating a node set, so combine for-each and call-template rather than using apply-templates. -->
        <xsl:for-each select="tokenize($ctStudyDesign,',')">
            <xsl:variable name="ctStudyDesignKeyValue" select="tokenize(.,':')"/>
            <xsl:choose>
                <xsl:when test="normalize-space($ctStudyDesignKeyValue[1]) = 'allocation'">
                    <xsl:variable name="ctAllocationValue" select="normalize-space($ctStudyDesignKeyValue[2])"/>
                    <xsl:element name="AllocationType">
                        <xsl:choose>
                            <xsl:when test="$ctAllocationValue = lower-case('Randomized')">Random allocation</xsl:when>
                            <xsl:when test="$ctAllocationValue = lower-case('Non-Randomized')">Non-random allocation</xsl:when>
                            <xsl:otherwise>
                                <xsl:variable name="errMsg"><xsl:value-of select="$globalNctID"/> - ERROR: UNDETERMINED for CT.gov Allocation:<xsl:value-of select="$ctAllocationValue"/></xsl:variable>
                                <xsl:message><xsl:value-of select="$errMsg"/></xsl:message>
                                <xsl:value-of select="$errMsg"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    
    <xsl:template name="ocreEmitScientificTitle">
        <xsl:element name="ScientificTitle">
            <xsl:choose>
                <xsl:when test="official_title != ''">
                    <xsl:value-of select="official_title"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="brief_title != ''">
                        <xsl:value-of select="brief_title"/>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    
    <xsl:template name="ocreEmitIRB">
        <!-- @CANNOTDO Cannot create IRB in HSDB using any values in CT.gov
            <xsl:element name="IRB"/>        
        -->
    </xsl:template>
    
    <xsl:template name="ocreEmitComparativeIntent">
        <!-- @CANNOTDO Cannot create ComparativeIntent in HSDB using any values in CT.gov
            <xsl:element name="ComparativeIntent"/>        
        -->
    </xsl:template>
    
    <xsl:template name="ocreEmitFundingRelation">
        <xsl:for-each select="//clinical_study/sponsors/*/agency">
            <xsl:element name="FundingRelation">
                <xsl:element name="Actor">
                    <xsl:element name="Organization">
                        <xsl:call-template name="ocreEmitOrganization">
                            <xsl:with-param name="ctName">
                                <xsl:value-of select="."/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:element>
                </xsl:element>
            </xsl:element>        
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="ocreEmitStudyProtocol">
        <xsl:element name="StudyProtocol">
            <xsl:attribute name="type" namespace="http://www.w3.org/2001/XMLSchema-instance">InterventionStudyProtocolType</xsl:attribute>
            <xsl:call-template name="ocreEmitOutcomeVariables"/>
            <xsl:call-template name="ocreEmitFactorVariables"/>
            <xsl:call-template name="ocreEmitDividedInto"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template name="ocreEmitOutcomeVariables">
        <xsl:for-each select="primary_outcome | secondary_outcome">
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
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="ocreEmitFactorVariables">
        <!-- @CANNOTDO Cannot create FactorVariable in HSDB using any values in CT.gov
        <xsl:element name="FactorVariable">
        </xsl:element>
        -->
    </xsl:template>
    
    <xsl:template name="ocreEmitDividedInto">
        <xsl:element name="DividedInto">
            <!-- since no epoch info mapped from ct.gov, just emit arms -->
            <xsl:call-template name="ocreEmitArm"/>
            <!-- @CANNOTDO Cannot create Epoch in HSDB using any values in CT.gov, so no need to choose
            <xsl:choose>
                <xsl:when test="1 = 1">
                    <xsl:call-template name="ocreEmitArm"/>
                </xsl:when>
                 <xsl:when test="1 = 0">
                    <xsl:call-template name="ocreEmitEpoch"/>
                </xsl:when>
            </xsl:choose>
            -->
        </xsl:element>
    </xsl:template>

    <xsl:template name="ocreEmitArm">
        <xsl:for-each select="arm_group/arm_group_label">
            <xsl:element name="Arm">
                <xsl:call-template name="ocreEmitArmContains">
                    <xsl:with-param name="ctArmGroupLabel">
                        <xsl:value-of select="."/>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:element name="Name">
                    <xsl:value-of select="."/>
                </xsl:element>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="ocreEmitArmContains">
        <xsl:param name="ctArmGroupLabel"/>
        <xsl:for-each select="../../intervention[arm_group_label=$ctArmGroupLabel]">
            <xsl:element name="Contains">
                <xsl:attribute name="type" namespace="http://www.w3.org/2001/XMLSchema-instance">
                    <xsl:value-of select="hsdb-ct:ct2HSDBInterventionTypeMap(intervention_type)"/>
                </xsl:attribute>
                <xsl:element name="EffectiveTime">
                    <xsl:element name="Description">
                        <xsl:value-of select="description"/>
                    </xsl:element>
                </xsl:element>
                <!-- @CANNOTDO Cannot create Code in HSDB using any values in CT.gov
                <xsl:element name="Code">
                    <xsl:comment>children-Description,DisplayName,CodeSystemVersion,CodeSystemName,Code</xsl:comment>
                </xsl:element>
                -->
                <xsl:element name="Name">
                    <xsl:value-of select="intervention_name"/>
                </xsl:element>
            </xsl:element>
        </xsl:for-each>
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
    <xsl:template name="ocreEmitStudyDesign">
        <xsl:variable name="ctStudyDesign" select="lower-case(normalize-space(study_design))"/>
        <xsl:variable name="ctStudyType" select="lower-case(normalize-space(study_type))"/>
        
        <!-- Do not emit the tag for certain recognized values of study_type -->
        <xsl:if test="$ctStudyType != 'expanded access'">
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
                                        <xsl:when test="$ctStudyDesignValue = lower-case('Ecologic or community studies')"><xsl:call-template name="ocreEmitStudyDesignFromStudyType"/></xsl:when>
                                        <xsl:when test="$ctStudyDesignValue = lower-case('Family-based')"><xsl:call-template name="ocreEmitStudyDesignFromStudyType"/></xsl:when>
                                        <xsl:when test="$ctStudyDesignValue = lower-case('other')"><xsl:call-template name="ocreEmitStudyDesignFromStudyType"/></xsl:when>
                                        <xsl:otherwise>
                                            <xsl:variable name="warnMsg"><xsl:value-of select="$globalNctID"/> - WARNING: UNDETERMINED for CT.gov study_design characteristic <xsl:value-of select="$ctStudyDesignKey"/>:<xsl:value-of select="$ctStudyDesignValue"/></xsl:variable>
                                            <xsl:message><xsl:value-of select="$warnMsg"/></xsl:message>
                                            <!-- Since warnMsg posted about unrecognized study_design, just use study_type to create value -->
                                            <xsl:call-template name="ocreEmitStudyDesignFromStudyType"/>
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
                                            <xsl:variable name="warnMsg"><xsl:value-of select="$globalNctID"/> - WARNING: UNDETERMINED for CT.gov study_design characteristic <xsl:value-of select="$ctStudyDesignKey"/>:<xsl:value-of select="$ctStudyDesignValue"/></xsl:variable>
                                            <xsl:message><xsl:value-of select="$warnMsg"/></xsl:message>
                                            <!-- Since warnMsg posted about unrecognized study_design, just use study_type to create value -->
                                            <xsl:call-template name="ocreEmitStudyDesignFromStudyType"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:when test="$ctStudyDesignKey = lower-case('Time Perspective')">
                                    <xsl:choose>
                                        <xsl:when test="$ctStudyDesignValue = lower-case('Cross-Sectional')">Cross-sectional study design</xsl:when>
                                        <xsl:otherwise>
                                            <!-- Don't put out a warning for values of Time Perspective we recognize from http://prsinfo.clinicaltrials.gov/definitions.html but
                                             do not choose to map to a distinct HSDB value 
                                        -->
                                            <xsl:if test="$ctStudyDesignValue != lower-case('Prospective') and $ctStudyDesignValue != lower-case('Retrospective') and $ctStudyDesignValue != lower-case('Other')">
                                                <xsl:variable name="warnMsg"><xsl:value-of select="$globalNctID"/> - WARNING: UNDETERMINED for CT.gov study_design characteristic <xsl:value-of select="$ctStudyDesignKey"/>:<xsl:value-of select="$ctStudyDesignValue"/></xsl:variable>
                                                <xsl:message><xsl:value-of select="$warnMsg"/></xsl:message>
                                            </xsl:if>
                                            <!-- Since warnMsg posted about unrecognized study_design, just use study_type to create value -->
                                            <xsl:call-template name="ocreEmitStudyDesignFromStudyType"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="ocreEmitStudyDesignFromStudyType"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template name="ocreEmitStudyDesignFromStudyType">
        <xsl:variable name="ctStudyType" select="lower-case(normalize-space(study_type))"/>
        <xsl:choose>
            <xsl:when test="$ctStudyType = lower-case('Interventional')">Interventional study design</xsl:when>
            <xsl:when test="$ctStudyType = lower-case('Observational Model')">Observational study design</xsl:when>
            <xsl:otherwise>
                <xsl:variable name="errMsg"><xsl:value-of select="$globalNctID"/> - ERROR: UNDETERMINED for CT.gov study_type = <xsl:value-of select="$ctStudyType"></xsl:value-of></xsl:variable>
                <xsl:message><xsl:value-of select="$errMsg"/></xsl:message>
                <xsl:value-of select="$errMsg"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
        
    <xsl:template name="ocreEmitPrincipalInvestigator">
        <xsl:for-each select="overall_official">
            <xsl:element name="PrincipalInvestigator">
                <xsl:call-template name="ocreEmitPersonSubtree">
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
        </xsl:for-each>
    </xsl:template>
        
    <!-- This is only emitting the elements of <Person>, since <Person> is visible as contact, but not as PI right now -->
    <xsl:template name="ocreEmitPersonSubtree">
        <xsl:param name="ctFirstName"/>
        <xsl:param name="ctLastName"/>
        <xsl:param name="ctAffiliation"/>
        <xsl:param name="ctEmail"/>
        <xsl:param name="ctPhone"/>
        <xsl:param name="ctPhoneExt"/>

        <xsl:if test="$ctAffiliation != ''">
            <xsl:element name="MemberOf">
                <xsl:call-template name="ocreEmitOrganization">
                    <xsl:with-param name="ctName">
                        <xsl:value-of select="affiliation"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:element>
        </xsl:if>
        <!-- We cannot extract info we want for a SponsoringRelation identifier or a PrincipalInvestigator from ct.gov
            <xsl:element name="Identifier">InstanceIdentifierType</xsl:element>
        -->
        <xsl:if test="$ctFirstName != ''">
            <xsl:element name="FirstName">
                <xsl:value-of select="$ctFirstName"/>
            </xsl:element>
        </xsl:if>
        <!-- We cannot extract info we want for a SponsoringRelation postal address, or a ContactForPublicQueries
             postal address, from ct.gov
            <xsl:call-template name="ocreEmitAddress-Postal">
        -->
        <xsl:if test="$ctEmail != ''">
            <xsl:call-template name="ocreEmitAddress-Email">
                <xsl:with-param name="ctEmail">
                    <xsl:value-of select="$ctEmail"/>                            
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="$ctPhone != ''">
            <xsl:call-template name="ocreEmitAddress-Telephone">
                <xsl:with-param name="ctPhone">
                    <xsl:value-of select="$ctPhone"/>                            
                </xsl:with-param>
                <xsl:with-param name="ctPhoneExt">
                    <xsl:value-of select="$ctPhoneExt"/>                            
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
        
        <xsl:if test="$ctLastName != ''">
            <xsl:element name="LastName">
                <xsl:value-of select="$ctLastName"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="ocreEmitOrganization">
        <xsl:param name="ctName"/>

        <!-- We cannot extract info we want for an organization identifier from ct.gov
        <xsl:call-template name="ocreEmitIdentifier">
            <xsl:with-param name="root"></xsl:with-param>
            <xsl:with-param name="name"></xsl:with-param>
        </xsl:call-template>
        -->
        <xsl:element name="Name"><xsl:value-of select="$ctName"/></xsl:element>
        <!-- We cannot extract info we want for an organization address from ct.gov
        <xsl:call-template name="ocreEmitAddress-Postal">
            <xsl:with-param name="ctStreet"></xsl:with-param>
            <xsl:with-param name="ctCity"></xsl:with-param>
            <xsl:with-param name="ctState"></xsl:with-param>
            <xsl:with-param name="ctZip"></xsl:with-param>
            <xsl:with-param name="ctCountry"></xsl:with-param>
        </xsl:call-template>
        -->
    </xsl:template>
    
    <!-- RecruitmentStatus="Recruitment not yet started" - when ct.gov overall_status is 'not yet recruiting'
                          |"Recruitment active"          - when ct.gov overall_status is 'recruiting'
                          |"Recruitment suspended"       - when ct.gov overall_status is 'suspended'
                          |"Recruitment will not start"  - when ct.gov overall_status is 'withdrawn'
                          |"Recruitment terminated"      - never from ct.gov clinical_study
                          |"Recruitment completed"       - never from ct.gov clinical_study
    -->
    <xsl:template name="ocreEmitRecruitmentStatus">
        <xsl:variable name="ctOverallStatus" select="lower-case(normalize-space(overall_status))"/>
        <!-- Do not emit the tag for certain recognized values of overall_status -->
        <xsl:if test="$ctOverallStatus != 'enrolling by invitation' and $ctOverallStatus != 'completed'">
            <xsl:element name="RecruitmentStatus">
            <xsl:choose>
                <xsl:when test="$ctOverallStatus = 'suspended'">Recruitment suspended</xsl:when>
                <xsl:when test="$ctOverallStatus = 'recruiting'">Recruitment active</xsl:when>
                <xsl:when test="$ctOverallStatus = 'withdrawn'">Recruitment will not start</xsl:when>
                <xsl:when test="$ctOverallStatus = 'not yet recruiting'">Recruitment not yet started</xsl:when>
                <xsl:when test="$ctOverallStatus = 'active, not recruiting'">Recruitment not active</xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="errMsg"><xsl:value-of select="$globalNctID"/> - ERROR: UNDETERMINED for CT.gov overall_status = <xsl:value-of select="$ctOverallStatus"/></xsl:variable>
                    <xsl:message><xsl:value-of select="$errMsg"/></xsl:message>
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
    <xsl:template name="ocreEmitStudyStatus">
        <xsl:variable name="ctOverallStatus" select="lower-case(normalize-space(overall_status))"/>
        <!-- Do not emit the tag for certain recognized values of overall_status -->
        <xsl:if test="$ctOverallStatus != 'enrolling by invitation' and $ctOverallStatus != 'suspended' and $ctOverallStatus != 'not yet recruiting'">
            <xsl:element name="StudyStatus">
            <xsl:choose>
                <xsl:when test="$ctOverallStatus = 'completed'">Study completed</xsl:when>
                <xsl:when test="$ctOverallStatus = 'recruiting'">Study active</xsl:when>
                <xsl:when test="$ctOverallStatus = 'withdrawn'">Study withdrawn</xsl:when>
                <xsl:when test="$ctOverallStatus = 'active, not recruiting'">Study active</xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="errMsg"><xsl:value-of select="$globalNctID"/> - ERROR: UNDETERMINED for CT.gov overall_status = <xsl:value-of select="$ctOverallStatus"/></xsl:variable>
                    <xsl:message><xsl:value-of select="$errMsg"/></xsl:message>
                    <xsl:value-of select="$errMsg"/>
                </xsl:otherwise>
            </xsl:choose>
            </xsl:element>
        </xsl:if>
     </xsl:template>
    
    <xsl:template name="ocreEmitContactForPublicQueries">
        <xsl:for-each select="overall_contact">
            <xsl:element name="ContactForPublicQueries">
                <!-- emitting the <Person> tag here for now, because of diff between PI and contact... -->
                <xsl:element name="Person">                    
                    <xsl:call-template name="ocreEmitPersonSubtree">
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
        </xsl:for-each>
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
            <xsl:if test="count($ctDateTokens) = 2"><xsl:value-of select="$ctDateTokens[2]"/></xsl:if>
            <xsl:if test="count($ctDateTokens) = 3"><xsl:value-of select="$ctDateTokens[3]"/></xsl:if>
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
                <xsl:message><xsl:value-of select="$errMsg"/></xsl:message>
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
                <xsl:variable name="errMsg"><xsl:value-of select="$globalNctID"/> - ERROR: UNDETERMINED for CT.gov intervention_type = <xsl:value-of select="$ctInterventionType"></xsl:value-of></xsl:variable>
                <xsl:message><xsl:value-of select="$errMsg"/></xsl:message>
                <xsl:value-of select="$errMsg"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
</xsl:stylesheet>