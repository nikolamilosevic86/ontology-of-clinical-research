/**
 * 
 */
package edu.uw.sig.ocre.datamodel;

import java.net.URI;

/**
 * @author detwiler
 * @date Jul 7, 2011
 */
public class Element implements XSDEntity
{
	private String name;
	//private String typeName;
	private String minOccurs;
	private String maxOccurs;
	private String entityURI;
	
	private Type type;
	
	public Element(String name, Type type, String entityURI)
	{
		this.name = name;
		this.type = type;
		this.entityURI = entityURI;
		
		// set default cardinality constraints
		minOccurs="0";
		maxOccurs="unbounded";
	}
	
	/**
	 * @return the name
	 */
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
	 * @return the type
	 */
	public Type getType()
	{
		return type;
	}
	/**
	 * @param type the type to set
	 */
	public void setType(Type type)
	{
		this.type = type;
	}
	/**
	 * @return the minOccurs
	 */
	public String getMinOccurs()
	{
		return minOccurs;
	}
	/**
	 * @param minOccurs the minOccurs to set
	 */
	public void setMinOccurs(String minOccurs)
	{
		this.minOccurs = minOccurs;
	}
	/**
	 * @return the maxOccurs
	 */
	public String getMaxOccurs()
	{
		return maxOccurs;
	}
	/**
	 * @param maxOccurs the maxOccurs to set
	 */
	public void setMaxOccurs(String maxOccurs)
	{
		this.maxOccurs = maxOccurs;
	}
	/**
	 * @return the entityURI
	 */
	public String getEntityURI()
	{
		return entityURI;
	}
	/**
	 * @param entityURI the entityURI to set
	 */
	public void setEntityURI(String entityURI)
	{
		this.entityURI = entityURI;
	}
	
	public String toString()
	{
		return "Element:name="+name+":type="+type+":uri="+entityURI;
	}

	/* (non-Javadoc)
	 * @see edu.uw.sig.ocre.datamodel.XSDEntity#toXMLString()
	 */
	@Override
	public String toXMLString()
	{
		/*
		 * <xsd:element name="LastName" type="xsd:string" OCRe:entityURI="http://purl.org/net/OCRe/OCRe.owl#OCRE900226"/>
		 * <xsd:element name="InstanceIdentifier" type="InstanceIdentifier" minOccurs="0" maxOccurs="unbounded" OCRe:entityURI="http://purl.org/net/OCRe/OCRe.owl#OCRE901005"/>
		 */
		
		StringBuffer xml = new StringBuffer();
		
		xml.append("<xsd:element");
		if(name!=null)
			xml.append(" name=\""+name+"\"");
		if(entityURI!=null)
			xml.append(" sawsdl:modelReference=\""+entityURI+"\"");
		if(minOccurs!=null)
		{
			xml.append(" minOccurs=\""+minOccurs+"\"");
		}
		if(maxOccurs!=null)
		{
			xml.append(" maxOccurs=\""+maxOccurs+"\"");
		}
		//xml.append(" minOccurs=\""+minOccurs+"\" maxOccurs=\""+maxOccurs+"\"");
		if(type.getName()==null)
		{
			// nested type definition
			xml.append(">");
			xml.append(type.toXMLString());
			xml.append("</xsd:element>");
		}
		else
		{
			xml.append(" type=\""+type.getName()+"\"/>");
		}
		
		/*
		if(type.getName()==null)
		{
			// nest type definition
			xml.append("<xsd:element name=\""+name+"\" OCRe:entityURI=\""+entityURI+"\">");
			xml.append(type.toXMLString());
			xml.append("</xsd:element>");
		}
		else
		{
			xml.append("<xsd:element name=\""+name+"\" type=\""+type.getName()+"\" OCRe:entityURI=\""+entityURI+"\"/>");
		}
		*/
		
		return xml.toString();
	}
}
