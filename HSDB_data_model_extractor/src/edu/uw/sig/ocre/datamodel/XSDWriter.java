/**
 * 
 */
package edu.uw.sig.ocre.datamodel;

import java.io.IOException;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Set;

import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.DocumentHelper;
import org.dom4j.io.OutputFormat;
import org.dom4j.io.XMLWriter;


/**
 * @author detwiler
 * @date Aug 4, 2011
 */
public class XSDWriter
{
	private List<String> namedTypesGenerated = new ArrayList<String>();
	
	public String generateXSDString(Set<XSDImport> imports, Element root, Collection<Type> types)
	{
		Document xsdDoc = generateXSDDocument(imports, root, types);
		if(xsdDoc==null)
			return null;
		
		StringWriter sw = new StringWriter();
		OutputFormat format = OutputFormat.createPrettyPrint();
        XMLWriter writer = new XMLWriter( sw, format );
        try
		{
			writer.write( xsdDoc );
		}
		catch (IOException e)
		{
			e.printStackTrace();
		}
		
		return sw.toString();
	}
	
	private Document generateXSDDocument(Set<XSDImport> imports, Element root, Collection<Type> types)
	{
		StringBuffer xsdSB = new StringBuffer();
		
		// write out schema tag
		xsdSB.append("<xsd:schema xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:sawsdl=\"http://purl.org/net/OCRe\"");
		for(XSDImport xsdimport : imports)
		{
			xsdSB.append(" xmlns:"+xsdimport.getImportNamespacePrefix()+"=\""+xsdimport.getImportNamespace()+"\"");
		}
		xsdSB.append(">");
		
		// write out imports
		for(XSDImport xsdimport : imports)
		{
			xsdSB.append(xsdimport.toXMLString());
		}
		xsdSB.append(generateXSDForElement(root));
		for(Type type : types)
		{
			String typeName = type.getName();
			if(typeName==null)
				continue; // unnamed types are nested types and are printed with elements
			if(namedTypesGenerated.contains(typeName))
				continue; // do not generate the same named type multiple times
			
			xsdSB.append(generateXSDForType(type));
			namedTypesGenerated.add(typeName);
		}
		xsdSB.append("</xsd:schema>");
		
		//test
		//System.err.println(xsdSB.toString());
		
		Document document = null;
		try
		{
			document = DocumentHelper.parseText(xsdSB.toString());
		}
		catch (DocumentException e)
		{
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        //Element root = document.addElement( "root" );
        
        return document;
	}
	
	private String generateXSDForElement(Element element)
	{
		return element.toXMLString();
	}
	
	private String generateXSDForType(Type type)
	{
		StringBuffer xsd = new StringBuffer();
		
		xsd.append(type.toXMLString());
		
		/*
		if(type instanceof ComplexTypeSequence)
		{
			// for sequence, write out sequence tags and write out nested elements
			ComplexTypeSequence cTypeSeq = (ComplexTypeSequence)type;
			xsd.append("<xsd:sequence>");
			for(Element element : cTypeSeq.getSequence())
			{
				xsd.append(element.toXMLString());
			}
			xsd.append("</xsd:sequence>");
			
			//test
			//xsd.append("\n");
		}
		else if(type instanceof ComplexTypeChoice)
		{
			// for choice, write out choice tags and then nested elements
			ComplexTypeChoice cTypeChoice = (ComplexTypeChoice)type;
			xsd.append("<xsd:choice>");
			for(Element element : cTypeChoice.getOptions())
			{
				xsd.append(element.toXMLString());
			}
			xsd.append("</xsd:choice>");
			
			//test
			//xsd.append("\n");
		}
		*/
		// TODO simple types or other comples types not yet handled
		
		return xsd.toString();
	}
}
