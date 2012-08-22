/**
 * 
 */
package edu.uw.sig.ocre.datamodel;

import java.util.ArrayList;
import java.util.List;

/**
 * @author detwiler
 * @date Aug 3, 2012
 */
public abstract class AttrEnabledType implements Type
{
	private List<Attribute> attrList = null;

	/**
	 * @return the attrList
	 */
	public List<Attribute> getAttrList()
	{
		return attrList;
	}

	/**
	 * @param attrList the attrList to set
	 */
	public void setAttrList(List<Attribute> attrList)
	{
		this.attrList = attrList;
	}
	
	
}
