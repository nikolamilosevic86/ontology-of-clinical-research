/**
 * 
 */
package edu.uw.sig.ocre.datamodel;

import java.util.List;
import java.util.Map;

/**
 * @author detwiler
 * @date Jul 7, 2011
 */
public class SimpleType extends AttrEnabledType
{
	private String name; 
	private String uri;
	
	private Map<String,String> attributeMap = null;
	
	public SimpleType()
	{

	}
	
	public SimpleType(String name, String uri)
	{
		this.name = name;
		this.uri = uri;
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

	/* (non-Javadoc)
	 * @see edu.uw.sig.ocre.datamodel.Type#toXMLString()
	 */
	@Override
	public String toXMLString()
	{
		StringBuffer xml = new StringBuffer();
		xml.append("<xsd:simpleType");
		if(this.getName()!=null)
			xml.append(" name=\""+this.getName()+"\"");
		if(this.getUri()!=null)
			xml.append(" sawsdl:modelReference=\""+this.getUri()+"\"");
		xml.append(">");

		xml.append("</xsd:simpleType>");
		
		return xml.toString();
	}

}
