/**
 * 
 */
package edu.uw.sig.ocre.datamodel;

import java.util.HashSet;
import java.util.Map;
import java.util.Set;

/**
 * @author detwiler
 * @date Jul 27, 2011
 */
public class ComplexTypeChoice implements Type
{
	private String name = null;
	private String uri = null;
	private Set<Element> options = new HashSet<Element>();
	
	private Map<String,String> attributeMap = null;
	
	public ComplexTypeChoice()
	{
		
	}
	
	public ComplexTypeChoice(Set<Element> options)
	{
		this.options = options;
	}

	/* (non-Javadoc)
	 * @see edu.uw.sig.ocre.datamodel.Type#getName()
	 */
	@Override
	public String getName()
	{
		return name;
	}

	/**
	 * @param name the name to set
	 */
	public void setName(String name)
	{
		this.name = name;
	}

	/**
	 * @return the uri
	 */
	public String getUri()
	{
		return uri;
	}

	/**
	 * @param uri the uri to set
	 */
	public void setUri(String uri)
	{
		this.uri = uri;
	}

	/**
	 * @return the options
	 */
	public Set<Element> getOptions()
	{
		return options;
	}

	/**
	 * @param options the options to set
	 */
	public void setOptions(Set<Element> options)
	{
		this.options = options;
	}

	
	/**
	 * @return the attributeMap
	 */
	public Map<String, String> getAttributeMap()
	{
		return attributeMap;
	}

	/**
	 * @param attributeMap the attributeMap to set
	 */
	public void setAttributeMap(Map<String, String> attributeMap)
	{
		this.attributeMap = attributeMap;
	}

	public String toString()
	{
		return "Choice:options="+options;
	}

	/* (non-Javadoc)
	 * @see edu.uw.sig.ocre.datamodel.XSDEntity#toXMLString()
	 */
	@Override
	public String toXMLString()
	{
		/*
		 * <xsd:choice>
		 * 	<xsd:element name="Organization" type="Organization" OCRe:entityURI="http://purl.org/net/OCRe/OCRe.owl#OCRE400079"/>
		 * 	<xsd:element name="Person" type="Person" OCRe:entityURI="http://purl.org/net/OCRe/OCRe.owl#OCRE400076"/>
		 * </xsd:choice>
		 */
		
		StringBuffer xml = new StringBuffer();
		xml.append("<xsd:complexType");
		if(name!=null)
			xml.append(" name=\""+name+"\"");
		if(uri!=null)
			xml.append(" sawsdl:modelReference=\""+uri+"\"");
		xml.append(">");
		xml.append("<xsd:choice>");
		for(XSDEntity option : options)
		{
			xml.append(option.toXMLString());
		}
		xml.append("</xsd:choice>");
		/*
		if(attributeMap!=null)
		{
			for(String attrName : attributeMap.keySet())
			{
				xml.append("xsd:attribute name=\""+attrName+"\" types=\""+attributeMap.get(attrName)+"\"/>");
			}
		}
		*/
		xml.append("</xsd:complexType>");
		return xml.toString();
	}
}
