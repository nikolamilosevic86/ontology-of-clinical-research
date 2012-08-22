/**
 * 
 */
package edu.uw.sig.ocre.datamodel;

/**
 * @author detwiler
 * @date Jul 9, 2012
 */
public class XSDImport implements XSDEntity
{
	private String importLocation = null;
	private String importNamespace = null;
	private String importNamespacePrefix = null;
	
	public XSDImport(String location, String namespace, String prefix)
	{
		this.importLocation = location;
		this.importNamespace = namespace;
		this.importNamespacePrefix = prefix;
	}

	/**
	 * @return the importLocation
	 */
	public String getImportLocation()
	{
		return importLocation;
	}

	/**
	 * @return the importNamespace
	 */
	public String getImportNamespace()
	{
		return importNamespace;
	}

	/**
	 * @return the importNamespacePrefix
	 */
	public String getImportNamespacePrefix()
	{
		return importNamespacePrefix;
	}

	@Override
	public String toXMLString()
	{
		// <xs:import namespace="http://purl.org/NET/OCRe/anno" schemaLocation="AnnotationImport.xsd"/>
		String importString = "<xsd:import namespace=\""+importNamespace+
				"\" schemaLocation=\""+importLocation+"\"/>";

		return importString;
	}

}
