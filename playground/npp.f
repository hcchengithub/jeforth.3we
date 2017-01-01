

    <js> (new ActiveXObject("NotepadPlusPlus.Application"))
    </jsV> constant npp // ( -- obj ) Notepad++ application ActiveX plugin base object 

    npp :> filename tib.
    npp :> version tib.
    npp :> pluginVersion tib.
    npp :> processId tib.
    npp :> hWnd tib.
    npp :> fileName tib.
    npp :> pluginFileName tib.
    npp :> pluginConfigurationFolder tib.
    npp :> activeEditor.index tib.
    npp :> editors.count tib.
    npp :> toolbarVisible tib.
    npp :> tabbarVisible tib.
    npp :> menuVisible tib.
    npp :> statusbarVisible tib.
    npp :> editors(0).files.count npp :> editors(1).files.count + ( Number of open files ) tib.
    \ npp :> messagebox("Npp-messagebox","msg-title","type=abortRetryIgnore,icon=information,default=2,model=taskModel")
    \ npp :: quit()
    
    \ Help of INppEditorList says:
    \   " This class contains the list of editor windows. These are always two: the primary and the 
    \   secondary editor. The primary editor is always visible, but the secondary editor can be invisible."
    \   An 'editor' has hWnd so it's an instance of Notepad++, however this is its internal design because
    \   users can't open more than one Notepad++ window as far as I know.
    
    \ ae doesn't need this way
    \ : ae ( -- obj ) \ Notepad++ active editor (or active instance) object
    \     npp :> activeeditor ;

    npp :> activeeditor constant ae // ( -- oEditor ) Notepad++ active editor object
                                    /// The object itself has the magic to always stick on the current active editor

    ae :> hWnd tib. \ The window handle of the current editor 
    ae :> codePage tib. \ The code page of the active file of an editor 
    ae :> files js> typeof(pop()) tib. \ The list of open files of an editor 
    ae :> index tib. \ The index of the current editor 
    ae :> language tib. \ The language of the active file of an editor 
    ae :> lines js> typeof(pop()) tib. \ The list of lines of the active file of the active editor
    ae :> readOnly tib. \ Specifies whether an editor is read-only. 
    ae :> selections js> typeof(pop()) tib. \ The list of selections of the active file of the active editor
    ae :> text :> length tib. \ The text of the active file of an editor 
    
    ae :> files constant files // ( -- oFiles ) Notepad++ files array of an editor
 
    files :> item(0).filename tib. \ method A
    files :> (0).filename tib. \ method A simplified
    files :> item(0).filename tib. \ method B
    files :> (0).filename tib. \ method B simplified
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
  