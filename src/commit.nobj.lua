-- Copyright (c) 2010 by Robert G. Jakabosky <bobby@sharedrealm.com>
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.

object "Commit" {
	c_source [[
typedef git_commit Commit;
]],
	extends "Object",
	constructor "lookup" {
		c_call {"GitError", "err"} "git_commit_lookup"
			{ "Commit *", "&this", "Repository *", "repo", "OID", "&id" },
	},
	c_function "create" {
		var_in{ "OID", "oid" },
		var_in{ "Repository *", "repo" },
		var_in{ "const char *", "update_ref" },
		var_in{ "Signature *", "author" },
		var_in{ "Signature *", "committer" },
		var_in{ "const char *", "message" },
		var_in{ "Tree *", "tree" },
		var_in{ "Commit *", "parent" },
		var_out{"GitError", "err"},
		c_source "pre" [[
	int parent_count = 0;
	const git_oid **p_oids;
	int n;
]],
		c_source[[
	/* count parents. */
	parent_count = lua_gettop(L) - ${parent::idx} + 1;
	/* valid parents.  The first parent commit is already validated. */
	for(n = 1; n < parent_count; n++) {
		obj_type_Commit_check(L, ${parent::idx} + n);
	}
	/* now it is safe to allocate oid array. */
	p_oids = malloc(parent_count * sizeof(git_oid *));

	/* copy oids from all parents into oid array. */
	p_oids[0] = git_object_id((git_object *)${parent});
	for(n = 1; n < parent_count; n++) {
		${parent} = obj_type_Commit_check(L, ${parent::idx} + n);
		p_oids[n] = git_object_id((git_object *)${parent});
	}

	${err} = git_commit_create(&(${oid}), ${repo}, ${update_ref},
		${author}, ${committer}, ${message}, git_object_id((git_object *)${tree}),
		parent_count, p_oids);
	/* free parent oid array. */
	free(p_oids);
]]
	},
	method "message" {
		c_method_call "const char *"  "git_commit_message" {}
	},
	method "message_short" {
		c_method_call "const char *"  "git_commit_message_short" {}
	},
	method "time" {
		c_method_call "time_t"  "git_commit_time" {}
	},
	method "time_offset" {
		c_method_call "int"  "git_commit_time_offset" {}
	},
	method "committer" {
		c_method_call "const Signature *"  "git_commit_committer" {}
	},
	method "author" {
		c_method_call "const Signature *"  "git_commit_author" {}
	},
	method "tree" {
		c_call "GitError" "git_commit_tree" { "Tree *", "&tree>1", "Commit *", "this" }
	},
	method "parentcount" {
		c_method_call "unsigned int"  "git_commit_parentcount" {}
	},
	method "parent" {
		c_call "GitError" "git_commit_parent"
			{ "Commit *", "&parent>1", "Commit *", "this", "unsigned int", "n" }
	},
}

