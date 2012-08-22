/**
 * 
 */
package edu.uw.sig.ocre.datamodel.util;

/**
 * @author detwiler
 * @date Jul 7, 2011
 */
public class StringUtils
{
	public static String toCamelCase(String input, boolean capitalizeFirstLetter)
	{
		StringBuffer sb = new StringBuffer();
		String[] segments = input.split("\\s");
		boolean firstSegment = true;
		for(String segment : segments)
		{
			if(segment.equals(""))
				continue;
			if(firstSegment && !capitalizeFirstLetter)
			{
				sb.append(segment);
				firstSegment = false;
				continue;
			}
			sb.append(String.format("%s%s", Character.toUpperCase(segment.charAt(0)), segment.substring(1)));
		}
		
		return sb.toString();
	}
	
	public static void main (String[] args)
	{
		System.err.println(StringUtils.toCamelCase("to caMel Case even if it iS weird!",true));
	}
}
