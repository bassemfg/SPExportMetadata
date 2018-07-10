using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.SharePoint;
using System.IO;
using System.Configuration;

namespace ConsoleApp1
{
    class CheckInFiles
    {
        static void CheckIn(string[] args)
        {

            string RootSiteCollection = System.Configuration.ConfigurationSettings.AppSettings["RootSiteCollection"];
            //int i = 0;
            int j = 0;
            Microsoft.SharePoint.SPSite siteColl = new SPSite(RootSiteCollection);
            StringBuilder sbFields = new StringBuilder();
            StringBuilder sbVals = new StringBuilder();

            StreamWriter sw = null;

            foreach (SPWeb web in siteColl.AllWebs)
            {
                Console.WriteLine("Processing site " + web.Url);
                sbFields.Length = 0;


                foreach (SPList list in web.Lists)
                {
                    Console.WriteLine("Processing list " + list.ID);
                    sbVals.Length = 0;
                    if (list.BaseType == SPBaseType.DocumentLibrary && list.Hidden == false)
                    {

                        SPDocumentLibrary documentLibrary = list as SPDocumentLibrary;
                        IEnumerable<SPFile> files = ExploreFolder(documentLibrary.RootFolder);

                        j = 0;
                        foreach (SPFile file in files)
                        {
                            try
                            {
                                if (file.CheckOutType != SPFile.SPCheckOutType.None)

                                { file.CheckIn(""); }
                            }
                            catch { }

                        }
                    }
                }
            }
        }

        private static IEnumerable<SPFile> ExploreFolder(SPFolder folder)
        {
            foreach (SPFile file in folder.Files)
            {
                yield return file;
            }
            foreach (SPFolder subFolder in folder.SubFolders)
            {
                foreach (SPFile file in ExploreFolder(subFolder))
                {
                    yield return file;
                }

            }
        }
    }
}