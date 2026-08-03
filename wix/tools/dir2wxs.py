#!/usr/bin/env python

import os
import argparse
import xml.etree.ElementTree as ET
import uuid
import re


autoidx = 0


def convert_dir(dir, comp_group, path):
    global autoidx

    with os.scandir(path) as it:
        dir_id = f"{comp_group.attrib['Id']}_dir{autoidx}"
        dir_comp = ET.SubElement(dir, "Component", Id=dir_id, Guid=str(uuid.uuid4()))
        ET.SubElement(comp_group, "ComponentRef", Id=dir_id)
        autoidx += 1
        for entry in it:
            if entry.is_file():
                file_id = f"{comp_group.attrib['Id']}_file{autoidx}"
                ET.SubElement(dir_comp, "File",
                    Id=file_id,
                    Name=entry.name,
                    Source="Z:" + os.path.abspath(entry.path),
                )
                autoidx += 1
            else:
                entry_file = ET.SubElement(dir, "Directory", Name=entry.name)
                convert_dir(entry_file, comp_group, entry.path)


def convert(dir_id, group_id, path):
    root = ET.Element("Wix", xmlns="http://wixtoolset.org/schemas/v4/wxs")
    frag = ET.SubElement(root, "Fragment")
    dir_ref = ET.SubElement(frag, "DirectoryRef", Id=dir_id)
    comp_group = ET.SubElement(frag, "ComponentGroup", Id=group_id)
    convert_dir(dir_ref, comp_group, path)
    return ET.ElementTree(root)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-component-group", type=str,
        help="ComponentGroup Id value", default="InstallFiles")
    parser.add_argument("-directory-ref", type=str,
        help="DirectoryRef Id value", default="INSTALLFOLDER")
    parser.add_argument("-dir", type=str,
        help="input directory", required=True)
    parser.add_argument("-wxs", type=str,
        help="output WXS", required=True)

    args = parser.parse_args()
    convert(args.directory_ref, args.component_group, args.dir).write(args.wxs)


if __name__ == "__main__":
    main()
