/**
 * 
 */
package edu.uw.sig.ocre.datamodel;

/**
 * @author detwiler
 * @date Aug 3, 2012
 */
public class Attribute implements XSDEntity
{
	private String attrName = null;
	private String attrType = null;
	
	public Attribute(String name, String type)
	{
		this.attrName = name;
		this.attrType = type;
	}
	
	/* (non-Javadoc)
	 * @see edu.uw.sig.ocre.datamodel.XSDEntity#toXMLString()
	 */
	@Override
	public String toXMLString()
	{
		// <xsd:attribute name="id" type="xsd:ID"/>
		StringBuffer xml = new StringBuffer();
		xml.append("<xsd:attribute name=\"");
		xml.append(attrName);
		xml.append("\" type=\"");
		xml.append(attrType);
		xml.append("\"/>");
		
		return xml.toString();
	}

}
