# git-pod

git-pod is a git command plugin to manage modularized software projects.

A pod is a set of files providing a certain (optional) functionality. For instance
multiple runtime platform specific implementations may be provided as pods. A
project instance can be combined out of all the available pods as needed.

Technically spoken a pod is a orphaned branch in the git repository. Combining
multiple pods to a project is done by merging the pod's branches into the project
branch. The metadata, like pod desctiptions, is stored in a .gitpod file on the
root directory.

git-pod supports the user managing all the pods and migrating changes between
pods and projects. Before using git pod on a local git repo one should issue
git pod setup once.

## Usage

The git pod command plugin provides various subcommands for pod management.
Each subcommand defines its own set of parameters as described below.

Usage: git pod <subcommand> [subcommand options]
Subcommands:
  add           Add files to a pod's index
  checkout      Create a worktree for pod
  commit        Commits currently staged files for pod
  create        Create a new pod
  list          List all available pods
  migrate       Migrate changes to pods
  remove        Remove a pod
  select        Select pods to be used
  setup         Configures the current repository to be used with git-pod.
  status        Status of index for a pod
  update        Update pod meta data
  upgrade       Upgrade used pods to latest version

### Add

The add subcommand is used to transfer files already committed on the
current project branch to a pod. The files must not exist on the pod already.
If the files are already available on the pod, you might want to use migrate
instead.

The files are added to the pod's index but not committed automatically. Thus
you may use add multiple time to transfer files in junks, even by switching
thru multiple source branches. In order to actually commit all new files to
the pod use the commit subcommand.

Usage: git pod add [options] <file> [<file> ...]
Add files to a pod's index
    file                             Files to be added to the pod's index
    -v, --[no-]verbose               Run verbosely
    -p, --pod NAME                   Pod to add the file to
    -b, --branch [NAME]              Pods branch to add file to

### checkout

The checkout subcommand is used to manually create worktree for the named pod.
All other subcommands manipulating a pod will create a worktree implicitly. All
the worktrees are stored in a .worktree subdirectory. You can feel free to chdir
to a pod's worktree and issue all git commands directly.

Usage: git pod checkout [options] <name>
Create a worktree for pod
    name                             Pod to create worktree for
    -v, --[no-]verbose               Run verbosely
    -b, --branch [NAME]              Select branch, default master

### commit

The commit subcommand just issues a git commit within the named pod's
worktree. This is used to actually apply changes done to a pod by other
subcommands like add or migrate.

Usage: git pod commit [options]
Commits currently staged files for pod
    -v, --[no-]verbose               Run verbosely
    -p, --pod NAME                   Pod to commit changes to
    -b, --branch [NAME]              Pods branch to commit changes to
    -m, --message MSG                Commit message

### create

Using create one can initialize a new, empty pod.

Usage: git pod create [options] <name>
Create a new pod
    name                             Name of pod to create
    -v, --[no-]verbose               Run verbosely
    -d, --desc=DESC                  Set pod description to DESC

### list 

List is used to print out all the available pods.

Usage: git pod list [options] [name ...]
List all available pods
    name                             Names (patterns) of pod to filter
    -v, --[no-]verbose               Run verbosely
    -u, --[no-]used                  Show only pods (not) used on the active branch


### Migrate

The migrate subcommand is used to transfer changes to already existing files
from the current checkout to the named pod(s). All given pods are diffed
against the current working copy. A files already part of a pod having changes
on the working branch, these changes are applied to the pods worktree. One
has to use commit after migrate in order to actually apply the changes.  

Usage: git pod migrate [options] [<pod> ...]
Migrate changes to pods
    pod                              Only changes to selected pods are migrated
    -v, --[no-]verbose               Run verbosely
    -b, --branch [NAME]              Pod branch to migrate changes to

### Remove

Remove is used to purge out the named pods from the repo by deleting all
pod branches. Project branches containing a removed pod are not affected.

Usage: git pod remove [options] <pod> [<pod> ...]
Remove a pod
    pod                              Selected pods are removed
    -v, --[no-]verbose               Run verbosely

### Select

Using the select subcommand one can bring in the files of the named pods to the
active project branch. The pod branches are merged into the current working copy.

Usage: git pod select [options] <name> [<name> ...]
Select pods to be used
    name                             Name(s) of pod(s) to be selected
    -v, --[no-]verbose               Run verbosely

### Setup

The setup subcommand configures the local git repo to be used with pods. The main
issue here is configuring the custom merge driver for the .gitpod metadata files.
Due to the storage of pod metadata in this common file, merging together pod
branches (i.e. by using select) will always cause merge conflicts.

Usage: git pod setup [options]
Configures the current repository to be used with git-pod.
    -v, --[no-]verbose               Run verbosely

### Status

Using the status subcommand one can inspect a pods branch index status, i.e.
to watch out for uncommitted changes.

Usage: git pod status [options] <pod>
Status of index for a pod
    pod                              Pod to give status for
    -v, --[no-]verbose               Run verbosely
    -b, --branch [NAME]              Pods branch to state, defaults to master

### Update

Update is used to modify a pods metadata, such as the description.

Usage: git pod update [options] <name>
Update pod meta data
    name                             Name of pod to update
    -v, --[no-]verbose               Run verbosely
    -d, --desc=DESC                  Set pod description to DESC

### Upgrade

The upgrade subcommand is used to upgrade one or all previously selected pods to
the latest version available. This is simply done be merging the pods branch to
the local working copy again.

Usage: git pod upgrade [options] [<name> ...]
Upgrade used pods to latest version
    name                             Name(s) of pod(s) to be upgraded, defaults to all selected
    -v, --[no-]verbose               Run verbosely
