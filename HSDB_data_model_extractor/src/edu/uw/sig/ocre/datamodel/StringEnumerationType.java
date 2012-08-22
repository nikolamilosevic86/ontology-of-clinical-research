/**
 * 
 */
package edu.uw.sig.ocre.datamodel;

import java.util.HashMap;
import java.util.Map;

import org.semanticweb.owlapi.model.IRI;

/**
 * @author Todd
 *
 */
public class StringEnumerationType extends SimpleType 
{
	private Map<String,IRI> enumElements = new HashMap<String,IRI>();
	
	public Map<String, IRI> getEnumElements() {
		return enumElements;
	}

	public void setEnumElements(Map<String, IRI> enumElements) {
		this.enumElements = enumElements;
	}

	public StringEnumerationType(String name, String uri)
	{
		super(name, uri);
	}

	/* (non-Javadoc)
	 * @see edu.uw.sig.ocre.datamodel.SimpleType#toXMLString()
	 */
	@Override
	public String toXMLString()
	{
		/*
		 * <xsd:simpleType name="TelecommunicationSchemeType" sawsdl:modelReference="http://purl.org/net/OCRe/OCRe.owl#OCRE400005">
		 * 	<xsd:restriction base="xsd:string">
		 * 		<xsd:enumeration value="Email" sawsdl:modelReference="http://purl.org/net/OCRe/OCRe.owl#OCRE400117"/>
		 * 		<xsd:enumeration value="HTTP" sawsdl:modelReference="http://purl.org/net/OCRe/OCRe.owl#OCRE400116"/>
		 * 		<xsd:enumeration value="Telephone" sawsdl:modelReference="http://purl.org/net/OCRe/OCRe.owl#OCRE400118"/><
		 * 		xsd:enumeration value="Fax" sawsdl:modelReference="http://purl.org/net/OCRe/OCRe.owl#OCRE400119"/>
		 * 	</xsd:restriction>
		 * </xsd:simpleType>
		 */
		
		StringBuffer xml = new StringBuffer();
		xml.append("<xsd:simpleType");
		if(this.getName()!=null)
			xml.append(" name=\""+this.getName()+"\"");
		if(this.getUri()!=null)
			xml.append(" sawsdl:modelReference=\""+this.getUri()+"\"");
		xml.append(">");
		if(!enumElements.isEmpty())
		{
			xml.append("<xsd:restriction base=\"xsd:string\">");
			for(String name : enumElements.keySet())
			{
				xml.append("<xsd:enumeration value=\""+name+"\" sawsdl:modelReference=\""+enumElements.get(name)+"\"/>");
			}
			xml.append("</xsd:restriction>");
		}
		xml.append("</xsd:simpleType>");
		
		return xml.toString();
	}
}
