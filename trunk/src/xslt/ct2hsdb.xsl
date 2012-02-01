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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://hsdbweb.s3.amazonaws.com/HSDB_xsd_V12.xsd"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:output method="xml" encoding="UTF-8" indent="yes" />

    <xsl:variable name="globalNctID" select="/clinical_study/id_info/nct_id"/>

    <!--
    Control the generated output using this top-level, imperatively programmed template so the
    output meets the sequence and cardinality specifications of the HSDB schema
    created by Protege from the OCRe ontology.  This is slightly askew because we want to
    create valid output, using as much of the input as we have mapped, rather than directly
    transform the input into something else.
    -->
    <xsl:template match="/clinical_study">
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
                <xsl:call-template name="ocreEmitIdentifier">
                    <xsl:with-param name="root">
                        <xsl:value-of select="id_info/nct_id"/>
                    </xsl:with-param>
                    <xsl:with-param name="name">ClinicalTrials.gov</xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="ocreEmitStudyStatus"/>
                
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template name="ocreEmitIdentifier">
        <xsl:param name="root"/>
        <xsl:param name="name"/>
        <xsl:element name="Identifier">
            <xsl:element name="Root">
                <xsl:value-of select="$root"/>
            </xsl:element>
            <xsl:element name="IdentifierName">
                <xsl:value-of select="$name"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    <xsl:template name="ocreEmitRecruitmentSites">
        <xsl:for-each select="location">
            <xsl:element name="RecruitmentSite">
                <xsl:element name="Name"><xsl:value-of select="facility/name"></xsl:value-of></xsl:element>
                <xsl:call-template name="ocreEmitAddress">
                    <xsl:with-param name="ctCity">
                        <xsl:value-of select="facility/address/city"/>
                    </xsl:with-param>
                    <xsl:with-param name="ctState">
                        <xsl:value-of select="facility/address/state"/>
                    </xsl:with-param>
                    <xsl:with-param name="ctZip">
                        <xsl:value-of select="facility/address/zip"/>
                    </xsl:with-param>
                    <xsl:with-param name="ctCountry">
                        <xsl:value-of select="facility/address/country"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="ocreEmitAddress">
        <xsl:param name="ctStreet"/>
        <xsl:param name="ctCity"/>
        <xsl:param name="ctState"/>
        <xsl:param name="ctZip"/>
        <xsl:param name="ctCountry"/>
        <xsl:param name="ctEmail"/>
        <xsl:if test="$ctStreet != '' or $ctCity != '' or $ctState != '' or $ctZip != '' or $ctCountry != ''">
            <xsl:element name="Address">
                <xsl:call-template name="ocreEmitPostalAddress">
                    <xsl:with-param name="ctZip"><xsl:value-of select="$ctZip"/></xsl:with-param>
                    <xsl:with-param name="ctCountry"><xsl:value-of select="$ctCountry"/></xsl:with-param>
                </xsl:call-template>
                <xsl:call-template name="ocreEmitAddressString">
                    <xsl:with-param name="val">
                        <xsl:if test="$ctStreet != ''">
                            <xsl:value-of select="$ctState"/><xsl:text> </xsl:text>
                        </xsl:if>
                        <xsl:value-of select="$ctCity"/>
                        <xsl:if test="$ctState != ''">
                            <xsl:text>, </xsl:text><xsl:value-of select="$ctState"/>
                        </xsl:if>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:element>
        </xsl:if>
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
    
    <xsl:template name="ocreEmitPostalAddress">
        <xsl:param name="ctZip"/>
        <xsl:param name="ctCountry"/>
        <xsl:element name="PostalAddress">
            <xsl:element name="Zip"><xsl:value-of select="$ctZip"/></xsl:element>
            <xsl:element name="Country"><xsl:value-of select="$ctCountry"/></xsl:element>
        </xsl:element>
    </xsl:template>
    
    <xsl:template name="ocreEmitAddressString">
        <xsl:param name="val"/>
        <xsl:element name="AddressString"><xsl:value-of select="$val"/></xsl:element>
    </xsl:template>

    <xsl:template name="ocreEmitTelecommunicationsAddress">
        <xsl:param name="schemeType"/>
        <xsl:element name="TelecommunicationAddress"><xsl:value-of select="$schemeType"/></xsl:element>
    </xsl:template>
    
    
    <xsl:template name="ocreEmitSponsoringRelation">
        <!--
            <xsl:element name="SponsoringRelation"/>
        -->
    </xsl:template>
    
    <xsl:template name="ocreEmitDescriptionDate">
        <xsl:element name="DescriptionDate">
            <xsl:call-template name="ctDateStandardizer">
                <xsl:with-param name="ctDateString">
                    <xsl:value-of select="lastchanged_date"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:element>
    </xsl:template>

    <!-- @TODO: confirm if this will be a required element, and what xsd:integer is appropriate when CT enrollment/@type is not Anticipated -->
    <xsl:template name="ocreEmitPlannedSampleSize">
        <xsl:variable name="ctEnrollment" select="enrollment"/>
        <xsl:variable name="ctEnrollmentType" select="lower-case(normalize-space(enrollment/@type))"/>
        <!--
        <xsl:element name="PlannedSampleSize">
            <xsl:choose>
                <xsl:when test="$ctEnrollmentType = 'anticipated'">
                    <xsl:value-of select="enrollment"/>
                </xsl:when>
                <xsl:otherwise>-1</xsl:otherwise>
            </xsl:choose>
        </xsl:element>
        -->
        <xsl:if test="$ctEnrollmentType = 'anticipated'">
            <xsl:element name="PlannedSampleSize"><xsl:value-of select="enrollment"/></xsl:element>
        </xsl:if>
    </xsl:template>
    
    <!-- @TODO: confirm if this will be a required element, and what xsd:integer is appropriate when CT enrollment/@type is not Actual -->
    <xsl:template name="ocreEmitActualSampleSize">
        <xsl:variable name="ctEnrollment" select="enrollment"/>
        <xsl:variable name="ctEnrollmentType" select="lower-case(normalize-space(enrollment/@type))"/>
        <!--
        <xsl:element name="ActualSampleSize">
            <xsl:choose>
                <xsl:when test="$ctEnrollmentType = 'actual'">
                    <xsl:value-of select="enrollment"/>
                </xsl:when>
                <xsl:otherwise>-1</xsl:otherwise>
            </xsl:choose>
        </xsl:element>
        -->
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
        <xsl:element name="ScientificTitle"><xsl:value-of select="official_title"></xsl:value-of></xsl:element>
    </xsl:template>
    
    <xsl:template name="ocreEmitIRB">
        <!--
            <xsl:element name="IRB"/>        
        -->
    </xsl:template>
    
    <xsl:template name="ocreEmitComparativeIntent">
        <!--
            <xsl:element name="ComparativeIntent"/>        
        -->
    </xsl:template>
    
    <xsl:template name="ocreEmitFundingRelation">
        <!--
            <xsl:element name="FundingRelation"/>        
        -->
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
        <xsl:for-each select="primary_outcome">
            <xsl:element name="OutcomeVariable">
                <xsl:element name="EffectiveTime">
                    <xsl:element name="Description">
                        <xsl:value-of select="time_frame"/>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="Name">
                    <xsl:value-of select="measure"/>
                </xsl:element>
                <xsl:element name="Priority">primary</xsl:element>
            </xsl:element>
        </xsl:for-each>
        <xsl:for-each select="secondary_outcome">
            <xsl:element name="OutcomeVariable">
                <xsl:element name="EffectiveTime">
                    <xsl:element name="Description">
                        <xsl:value-of select="time_frame"/>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="Name">
                    <xsl:value-of select="measure"/>
                </xsl:element>
                <xsl:element name="Priority">secondary</xsl:element>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="ocreEmitFactorVariables">
        <!--
        <xsl:element name="FactorVariable">
        </xsl:element>
        -->
    </xsl:template>
    
    <xsl:template name="ocreEmitDividedInto">
        <xsl:element name="DividedInto">
            <!-- No mapping for creating EPOCH nodes yet, not sure what criteria will be... -->
            <xsl:choose>
                <xsl:when test="1 = 1">
                    <xsl:call-template name="ocreEmitArm"/>
                </xsl:when>
                <!--
                <xsl:when test="1 = 0">
                    <xsl:call-template name="ocreEmitEpoch"/>
                </xsl:when>
                -->
            </xsl:choose>
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
                    <xsl:call-template name="ct2HSDBInterventionTypeMap">
                        <xsl:with-param name="ctInterventionType">
                            <xsl:value-of select="intervention_type"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:attribute>
                <xsl:element name="EffectiveTime">
                    <xsl:element name="Description">
                        <xsl:value-of select="description"/>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="Code">
                    <xsl:comment>Description,DisplayName,CodeSystemVersion,CodeSystemName,Code</xsl:comment>
                </xsl:element>
                <xsl:element name="Name">
                    <xsl:value-of select="intervention_name"/>
                </xsl:element>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>
    
    <!-- StudyDesignType="Case-crossover study design"    - when ct.gov study_design has Observational Model: Case-Crossover
        |"Parallel group study design"    - when ct.gov study_design has Intervention Model: Parallel Assignment
        |"Crossover study design"         - when ct.gov study_design has Intervention Model: Crossover Assignment
        |"Single group study design"      - when ct.gov study_design has Intervention Model: Single Group Assignment
        |"Cohort study design"            - when ct.gov study_design has Observational Model: Cohort
        |"Case-control study design"      - when ct.gov study_design has Observational Model: Case Control
        |"Cross-sectional study design"   - when ct.gov study_design has Time Perspective: Cross-Sectional
        |"N-of-1 crossover study design"  - never from ct.gov clinical_study
        |"Quantitative study design"      - never from ct.gov clinical_study
        |"Qualitative study design"       - never from ct.gov clinical_study
        |"Observational study design"     - when none of above, and ct.gov study_type is Observational
        |"Interventional study design"    - when none of above, and ct.gov study_type is Interventional
        
    -->
    <xsl:template name="ocreEmitStudyDesign">
        
        <xsl:variable name="ctStudyDesign" select="study_design"/>
        <xsl:variable name="ctStudyType" select="study_type"/>
        
        <!-- Assume the study_design xsd:string only uses the comma to separate attributes, not within attribute values. -->
        <!-- Assume the CT.gov study_design xsd:string will contain only one of {Observational Model, Intervention Model, Time Perspective} -->
        <!-- Not evaluating a node set, so combine for-each and call-template rather than using apply-templates. -->
        <xsl:choose>
            <xsl:when test="contains(lower-case($ctStudyDesign),lower-case('Observational Model')) or
                contains(lower-case($ctStudyDesign),lower-case('Intervention Model')) or
                contains(lower-case($ctStudyDesign),lower-case('Time Perspective'))">
                <xsl:for-each select="tokenize($ctStudyDesign,',')">
                    <xsl:variable name="ctStudyDesignKeyValue" select="tokenize(.,':')"/>
                    <xsl:variable name="ctStudyDesignKey" select="lower-case(normalize-space($ctStudyDesignKeyValue[1]))"/>
                    <xsl:variable name="ctStudyDesignValue" select="lower-case(normalize-space($ctStudyDesignKeyValue[2]))"/>
                        <xsl:choose>
                            <xsl:when test="$ctStudyDesignKey = lower-case('Observational Model')">
                                <xsl:element name="StudyDesign">
                                    <xsl:choose>
                                        <xsl:when test="$ctStudyDesignValue = lower-case('Case-Crossover')">Case-crossover study design</xsl:when>
                                        <xsl:when test="$ctStudyDesignValue = lower-case('Cohort')">Cohort study design</xsl:when>
                                        <xsl:when test="$ctStudyDesignValue = lower-case('Case Control')">Case-control study design</xsl:when>
                                        <xsl:when test="$ctStudyDesignValue = lower-case('Ecologic or community studies')"><xsl:call-template name="ocreEmitStudyDesignFromStudyType"/></xsl:when>
                                        <xsl:when test="$ctStudyDesignValue = lower-case('Family-based')"><xsl:call-template name="ocreEmitStudyDesignFromStudyType"/></xsl:when>
                                        <xsl:when test="$ctStudyDesignValue = lower-case('other')"><xsl:call-template name="ocreEmitStudyDesignFromStudyType"/></xsl:when>
                                        <xsl:otherwise>
                                            <xsl:variable name="errMsg"><xsl:value-of select="$globalNctID"/> - ERROR: UNDETERMINED for CT.gov study_design characteristic <xsl:value-of select="$ctStudyDesignKey"/>:<xsl:value-of select="$ctStudyDesignValue"/></xsl:variable>
                                            <xsl:message><xsl:value-of select="$errMsg"/></xsl:message>
                                            <xsl:value-of select="$errMsg"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:element>
                            </xsl:when>
                            <xsl:when test="$ctStudyDesignKey = lower-case('Intervention Model')">
                                <xsl:element name="StudyDesign">
                                    <xsl:choose>
                                        <xsl:when test="$ctStudyDesignValue = lower-case('Parallel Assignment')">Parallel group study design</xsl:when>
                                        <xsl:when test="$ctStudyDesignValue = lower-case('Crossover Assignment')">Crossover study design</xsl:when>
                                        <xsl:when test="$ctStudyDesignValue = lower-case('Single Group Assignment')">Single group study design</xsl:when>
                                        <xsl:otherwise>
                                            <xsl:variable name="errMsg"><xsl:value-of select="$globalNctID"/> - ERROR: UNDETERMINED for CT.gov study_design characteristic <xsl:value-of select="$ctStudyDesignKey"/>:<xsl:value-of select="$ctStudyDesignValue"/></xsl:variable>
                                            <xsl:message><xsl:value-of select="$errMsg"/></xsl:message>
                                            <xsl:value-of select="$errMsg"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:element>
                            </xsl:when>
                        <xsl:when test="$ctStudyDesignKey = lower-case('Time Perspective')">
                            <xsl:element name="StudyDesign">
                                <xsl:choose>
                                    <xsl:when test="$ctStudyDesignValue = lower-case('Cross-Sectional')">Cross-sectional study design</xsl:when>
                                    <xsl:otherwise>
                                        <xsl:variable name="errMsg"><xsl:value-of select="$globalNctID"/> - ERROR: UNDETERMINED for CT.gov study_design characteristic <xsl:value-of select="$ctStudyDesignKey"/>:<xsl:value-of select="$ctStudyDesignValue"/></xsl:variable>
                                        <xsl:message><xsl:value-of select="$errMsg"/></xsl:message>
                                        <xsl:value-of select="$errMsg"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="ocreEmitStudyDesignFromStudyType"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="ocreEmitStudyDesignFromStudyType">
        <xsl:variable name="ctStudyType" select="lower-case(normalize-space(study_type))"/>
        <xsl:element name="StudyDesign">
            <xsl:choose>
                <xsl:when test="$ctStudyType = lower-case('Interventional')">Interventional study design</xsl:when>
                <xsl:when test="$ctStudyType = lower-case('Observational Model')">Observational study design</xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="errMsg"><xsl:value-of select="$globalNctID"/> - ERROR: UNDETERMINED for CT.gov study_type = <xsl:value-of select="$ctStudyType"></xsl:value-of></xsl:variable>
                    <xsl:message><xsl:value-of select="$errMsg"/></xsl:message>
                    <xsl:value-of select="$errMsg"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
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

        <!-- xsl:element name="Person" -->
            <xsl:if test="$ctAffiliation != ''">
                <xsl:element name="MemberOf">
                    <xsl:call-template name="ocreEmitOrganization">
                        <xsl:with-param name="ctName">
                            <xsl:value-of select="affiliation"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:element>
            </xsl:if>
            <!--
                <xsl:element name="Identifier">InstanceIdentifierType</xsl:element>
            -->
            <xsl:element name="FirstName">
                <xsl:value-of select="$ctFirstName"/>
            </xsl:element>
            <!--
                <xsl:element name="Address">
                <xsl:element name="Address">
                <xsl:element name="PostalAddress">
                <xsl:element name="Zip"/>
                <xsl:element name="Country"/>
                </xsl:element>
                <xsl:element name="AddressString"/>
                </xsl:element>
                </xsl:element>
            -->
            <xsl:element name="LastName">
                <xsl:value-of select="$ctLastName"/>
            </xsl:element>
        <!-- /xsl:element -->
    </xsl:template>
    
    <xsl:template name="ocreEmitOrganization">
        <xsl:param name="ctName"/>
        
        <xsl:call-template name="ocreEmitIdentifier">
            <xsl:with-param name="root">
            </xsl:with-param>
            <xsl:with-param name="name">
            </xsl:with-param>
        </xsl:call-template>
        <xsl:element name="Name"><xsl:value-of select="$ctName"/></xsl:element>
        <xsl:call-template name="ocreEmitAddress">
            <xsl:with-param name="ctStreet">
            </xsl:with-param>
            <xsl:with-param name="ctCity">
            </xsl:with-param>
            <xsl:with-param name="ctState">
            </xsl:with-param>
            <xsl:with-param name="ctZip">
            </xsl:with-param>
            <xsl:with-param name="ctCountry">
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="ocreEmitRecruitmentStatus">
        <xsl:variable name="ctOverallStatus" select="lower-case(normalize-space(overall_status))"/>
            <xsl:choose>
                <xsl:when test="$ctOverallStatus = 'suspended'">
                    <xsl:element name="RecruitmentStatus">Recruitment suspended</xsl:element>
                </xsl:when>
                <xsl:when test="$ctOverallStatus = 'recruiting'">
                    <xsl:element name="RecruitmentStatus">Recruitment active</xsl:element>
                </xsl:when>
                <xsl:when test="$ctOverallStatus = 'withdrawn'">
                    <xsl:element name="RecruitmentStatus">Recruitment will not start</xsl:element>
                </xsl:when>
                <xsl:when test="$ctOverallStatus = 'not yet recruiting'">
                    <xsl:element name="RecruitmentStatus">Recruitment not yet started</xsl:element>
                </xsl:when>
                <xsl:when test="$ctOverallStatus = 'completed'"/><!-- recognize value, but no output node -->
                <xsl:otherwise>
                    <xsl:variable name="errMsg"><xsl:value-of select="$globalNctID"/> - ERROR: UNDETERMINED for CT.gov overall_status = <xsl:value-of select="$ctOverallStatus"/></xsl:variable>
                    <xsl:message><xsl:value-of select="$errMsg"/></xsl:message>
                    <xsl:element name="RecruitmentStatus"><xsl:value-of select="$errMsg"/></xsl:element>
                </xsl:otherwise>
            </xsl:choose>
    </xsl:template>
    
    <xsl:template name="ocreEmitStudyStatus">
        <xsl:variable name="ctOverallStatus" select="lower-case(normalize-space(overall_status))"/>
        
            <xsl:choose>
                <xsl:when test="$ctOverallStatus = 'completed'"><xsl:element name="StudyStatus">Study completed</xsl:element></xsl:when>
                <xsl:when test="$ctOverallStatus = 'recruiting'"><xsl:element name="StudyStatus">Study active</xsl:element></xsl:when>
                <xsl:when test="$ctOverallStatus = 'suspended'"/><!-- recognize value, but no output -->
                <xsl:when test="$ctOverallStatus = 'withdrawn'"/><!-- recognize value, but no output -->
                <xsl:when test="$ctOverallStatus = 'not yet recruiting'"/><!-- recognize value, but no output -->
                <xsl:otherwise>
                    <xsl:variable name="errMsg"><xsl:value-of select="$globalNctID"/> - ERROR: UNDETERMINED for CT.gov overall_status = <xsl:value-of select="$ctOverallStatus"/></xsl:variable>
                    <xsl:message><xsl:value-of select="$errMsg"/></xsl:message>
                    <xsl:element name="StudyStatus"><xsl:value-of select="$errMsg"/></xsl:element>
                </xsl:otherwise>
            </xsl:choose>
        
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
            3. If there are threee tokens, the middle on indicates the day of the month
            4. The month is represented with the full US English word
            5. Non-alphanumeric characters, such as comma or period, can be removed from strings
            6. There are no two digit representations of the year in CT.gov
    -->
    <xsl:template name="ctDateStandardizer">
        <xsl:param name="ctDateString"/>
        <xsl:variable name="ctDateTokens" select="tokenize($ctDateString,'\s+')"/>
        <xsl:if test="count($ctDateTokens) = 3">
            <xsl:value-of select="$ctDateTokens[3]"/>
            <xsl:text>-</xsl:text>
            <xsl:call-template name="enUsMonthNumber">
                <xsl:with-param name="enUsMonthString">
                    <xsl:value-of select="$ctDateTokens[1]"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:text>-</xsl:text>
            <xsl:if test="number(replace($ctDateTokens[2],'[,]','')) &lt; 10">0</xsl:if><xsl:value-of select="replace($ctDateTokens[2],'[,]','')"/>
        </xsl:if>
        <xsl:if test="count($ctDateTokens) = 2">
            <xsl:value-of select="$ctDateTokens[2]"/>
            <xsl:text>-</xsl:text>
            <xsl:call-template name="enUsMonthNumber">
                <xsl:with-param name="enUsMonthString">
                    <xsl:value-of select="$ctDateTokens[1]"/>
                </xsl:with-param>
            </xsl:call-template>
            <!-- When only month and year are specified, use 1st to get a valid xsl:date -->
            <xsl:text>-01</xsl:text>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="enUsMonthNumber">
        <xsl:param name="enUsMonthString"/>
        <xsl:if test="lower-case($enUsMonthString) = 'january'">01</xsl:if>
        <xsl:if test="lower-case($enUsMonthString) = 'february'">02</xsl:if>
        <xsl:if test="lower-case($enUsMonthString) = 'march'">03</xsl:if>
        <xsl:if test="lower-case($enUsMonthString) = 'april'">04</xsl:if>
        <xsl:if test="lower-case($enUsMonthString) = 'may'">05</xsl:if>
        <xsl:if test="lower-case($enUsMonthString) = 'june'">06</xsl:if>
        <xsl:if test="lower-case($enUsMonthString) = 'july'">07</xsl:if>
        <xsl:if test="lower-case($enUsMonthString) = 'august'">08</xsl:if>
        <xsl:if test="lower-case($enUsMonthString) = 'september'">09</xsl:if>
        <xsl:if test="lower-case($enUsMonthString) = 'october'">10</xsl:if>
        <xsl:if test="lower-case($enUsMonthString) = 'november'">11</xsl:if>
        <xsl:if test="lower-case($enUsMonthString) = 'december'">12</xsl:if>
    </xsl:template>

    <xsl:template name="ct2HSDBInterventionTypeMap">
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
    </xsl:template>
    
</xsl:stylesheet>