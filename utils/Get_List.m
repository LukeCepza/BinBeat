function out = Get_List(path,type)
    list_dir=dir(fullfile(path,type));
    list_dir={list_dir.name}';
    out=list_dir;
end