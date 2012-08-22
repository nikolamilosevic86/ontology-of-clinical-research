/**
 * 
 */
package edu.uw.sig.ocre.datamodel;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * @author detwiler
 * @date Jul 12, 2012
 */
public class ComplexTypeAttrExt extends AttrEnabledType
{
	private String name;
	private String uri;
	private Type superType;

	/* (non-Javadoc)
	 * @see edu.uw.sig.ocre.datamodel.XSDEntity#toXMLString()
	 */
	@Override
	public String toXMLString()
	{
		/*
		 * <xs:complexType>
		 * 	<xs:complexContent>
		 * 		<xs:extension base="ArmType">
		 * 			<xs:attribute name="id" type="xs:ID"/>
		 * 		</xs:extension>
		 * 	</xs:complexContent>
		 * </xs:complexType>
		 */
		
		StringBuffer xml = new StringBuffer();
		xml.append("<xsd:complexType");
		if(name!=null)
			xml.append(" name=\""+name+"\"");
		if(uri!=null)
			xml.append(" sawsdl:modelReference=\""+uri+"\"");
		xml.append(">");
		xml.append("<xsd:complexContent>");
		xml.append("<xsd:extension base=\""+superType.getName()+"\"");
		if(superType.getUri()!=null)
			xml.append(" sawsdl:modelReference=\""+superType.getUri()+"\"");
		xml.append(">");
		
		List<Attribute> attrs = getAttrList();
		if(attrs!=null)
		{
			for(Attribute attr : attrs)
			{
				xml.append(attr.toXMLString());
			}
		}
		xml.append("</xsd:extension>");
		xml.append("</xsd:complexContent>");
		xml.append("</xsd:complexType>");
		return xml.toString();
	}

	/* (non-Javadoc)
	 * @see edu.uw.sig.ocre.datamodel.Type#getName()
	 */
	@Override
	public String getName()
	{
		return name;
	}

	/* (non-Javadoc)
	 * @see edu.uw.sig.ocre.datamodel.Type#getUri()
	 */
	@Override
	public String getUri()
	{
		return uri;
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

}
