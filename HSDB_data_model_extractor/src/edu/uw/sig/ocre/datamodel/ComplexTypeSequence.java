/**
 * 
 */
package edu.uw.sig.ocre.datamodel;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * @author detwiler
 * @date Jul 7, 2011
 */
public class ComplexTypeSequence extends AttrEnabledType
{
	private String name;
	private String uri;
	private List<Element> sequence = new ArrayList<Element>();
	private Type superType;

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

	public List<Element> getSequence() {
		return sequence;
	}

	public void setSequence(List<Element> sequence) {
		this.sequence = sequence;
	}
	
	/**
	 * @return the superType
	 */
	public Type getSuperType()
	{
		return superType;
	}

	/**
	 * @param superType the superType to set
	 */
	public void setSuperType(Type superType)
	{
		this.superType = superType;
	}

	/* (non-Javadoc)
	 * @see edu.uw.sig.ocre.datamodel.AttrEnabledType#getAttrList()
	 */
	@Override
	public List<Attribute> getAttrList()
	{
		// TODO Auto-generated method stub
		return super.getAttrList();
	}

	/* (non-Javadoc)
	 * @see edu.uw.sig.ocre.datamodel.AttrEnabledType#setAttrList(java.util.List)
	 */
	@Override
	public void setAttrList(List<Attribute> attrList)
	{
		// TODO Auto-generated method stub
		super.setAttrList(attrList);
	}

	public String toString()
	{
		return "ComplexType:name="+name+":uri="+uri+":sequence="+sequence.toString();
	}
	
	public String toXMLString()
	{
		/*
		 * <xsd:complexType name="Person" OCRe:entityURI="http://purl.org/net/OCRe/OCRe.owl#OCRE400076">
		 * 	<xsd:sequence>
		 * 		<xsd:element name="FirstName" type="xsd:string" OCRe:entityURI="http://purl.org/net/OCRe/OCRe.owl#OCRE900225"/>
		 * 		<xsd:element name="LastName" type="xsd:string" OCRe:entityURI="http://purl.org/net/OCRe/OCRe.owl#OCRE900226"/>
		 * 		<xsd:element name="InstanceIdentifier" type="InstanceIdentifier" minOccurs="0" maxOccurs="unbounded" OCRe:entityURI="http://purl.org/net/OCRe/OCRe.owl#OCRE901005"/>
		 * 		<xsd:element name="Address" type="Address" minOccurs="0" maxOccurs="unbounded" OCRe:entityURI="http://purl.org/net/OCRe/OCRe.owl#OCRE901003"/>
		 * 		<xsd:element name="Organization" type="Organization" minOccurs="0" OCRe:entityURI="http://purl.org/net/OCRe/OCRe.owl#OCRE900064"/>
		 * 	</xsd:sequence>
		 * </xsd:complexType>
		 */
		
		boolean isExt = false;
		if(superType!=null)
			isExt=true;
		
		StringBuffer xml = new StringBuffer();
		xml.append("<xsd:complexType");
		if(name!=null)
			xml.append(" name=\""+name+"\"");
		if(uri!=null)
			xml.append(" sawsdl:modelReference=\""+uri+"\"");
		xml.append(">");
		if(isExt)
		{
			xml.append("<xsd:complexContent>");
			xml.append("<xsd:extension base=\""+superType.getName()+"\"");
			if(superType.getUri()!=null)
				xml.append(" sawsdl:modelReference=\""+superType.getUri()+"\"");
			xml.append(">");
		}
		if(!sequence.isEmpty())
		{
			xml.append("<xsd:all>");
			for(XSDEntity entity : sequence)
			{
				xml.append(entity.toXMLString());
			}
			xml.append("</xsd:all>");
		}
		List<Attribute> attrs = getAttrList();
		if(attrs!=null)
		{
			for(Attribute attr : attrs)
			{
				xml.append(attr.toXMLString());
			}
		}
		if(isExt)
		{
			xml.append("</xsd:extension>");
			xml.append("</xsd:complexContent>");
		}
		xml.append("</xsd:complexType>");
		
		return xml.toString();
	}
}
