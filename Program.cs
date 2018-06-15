using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.SharePoint;
using System.IO;

namespace ConsoleApp1
{
    class Program
    {
        static void Main(string[] args)
        {
            int i = 0;
            int j = 0;
            Microsoft.SharePoint.SPSite siteColl = new SPSite(@"https://ic3.icat.org.au/group/catprojects/");//http://sp2013vm/
            StringBuilder sbFields = new StringBuilder();
            StringBuilder sbVals = new StringBuilder();

            StreamWriter sw = null;

            foreach (SPWeb web in siteColl.AllWebs)
            {
                sbFields.Length = 0;
                

                foreach (SPList list in web.Lists)
                {
                    sbVals.Length = 0;
                    if (list.BaseType == SPBaseType.DocumentLibrary && list.Hidden==false )
                    {
                        j = 0;
                        foreach (SPItem item in list.Items)
                        {

                            i = 0;
                            foreach (SPField field in item.Fields)
                            {
                                if (field.Hidden == false && field.Sealed == false)
                                {
                                    if (j == 0)
                                    {
                                        sbFields.Append(field.ToString());
                                        sbFields.Append(',');
                                    }
                                    if (item[i] != null)
                                        sbVals.Append(item[i].ToString());
                                    sbVals.Append(',');
                                    i++;
                                }
                            }
                            //remove last ','
                            sbFields.Length = sbFields.Length - 1;
                            sbVals.Length = sbVals.Length - 1;
                            // add new lines
                            sbFields.Append(@"
");                         sbVals.Append(@"
");
                            j++;
                        }
                    }

                    sbFields.Append(sbVals.ToString());
                    sbFields.Append(@"
");

                }

                sw = new StreamWriter(@"c:\metadata_" + web.Url.Substring(web.Url.LastIndexOf(@"/")+1) + @".csv");

                sw.Write(sbFields.ToString());
                sw.Write(sbVals.ToString());
                sw.Flush();
                sw.Close();

            }
        }
    }
}