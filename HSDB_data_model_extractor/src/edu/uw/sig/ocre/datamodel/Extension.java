/**
 * 
 */
package edu.uw.sig.ocre.datamodel;

/**
 * @author detwiler
 * @date Jul 27, 2011
 */
public class Extension implements XSDEntity
{
	private String base;
	private String uri;
	
	public Extension(String base, String uri)
	{
		this.base = base;
		this.uri = uri;
	}
	/**
	 * @return the base
	 */
	public String getBase()
	{
		return base;
	}
	
	/**
	 * @param base the base to set
	 */
	public void setBase(String base)
	{
		this.base = base;
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
	 * @see edu.uw.sig.ocre.datamodel.XSDEntity#toXMLString()
	 */
	@Override
	public String toXMLString()
	{
		// TODO Auto-generated method stub
		return null;
	}
}
