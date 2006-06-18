/* valaenum.vala
 *
 * Copyright (C) 2006  Jürg Billeter
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.

 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.

 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
 *
 * Author:
 * 	Jürg Billeter <j@bitron.ch>
 */

using GLib;

namespace Vala {
	public class Enum : Type_ {
		List<EnumValue> values;

		public static ref Enum new (string name, SourceReference source) {
			return (new Enum (name = name, source_reference = source));
		}
		
		public void add_value (EnumValue value) {
			values.append (value);
		}
		
		public override void accept (CodeVisitor visitor) {
			visitor.visit_begin_enum (this);
			
			foreach (EnumValue value in values) {
				value.accept (visitor);
			}

			visitor.visit_end_enum (this);
		}

		string cname;
		public override string get_cname () {
			if (cname == null) {
				cname = "%s%s".printf (@namespace.get_cprefix (), name);
			}
			return cname;
		}
		
		public override ref string get_upper_case_cname (string infix) {
			return "%s%s".printf (@namespace.get_lower_case_cprefix (), Namespace.camel_case_to_lower_case (name)).up ();
		}

		public override bool is_reference_type () {
			return false;
		}
		
		public void set_cname (string! cname) {
			this.cname = cname;
		}
		
		string cprefix;
		public string get_cprefix () {
			if (cprefix == null) {
				cprefix = "%s_".printf (get_upper_case_cname (null));
			}
			return cprefix;
		}
		
		public void set_cprefix (string! cprefix) {
			this.cprefix = cprefix;
		}
		
		void process_ccode_attribute (Attribute! a) {
			foreach (NamedArgument arg in a.args) {
				if (arg.name == "cname") {
					/* this will already be checked during semantic analysis */
					if (arg.argument is LiteralExpression) {
						var lit = ((LiteralExpression) arg.argument).literal;
						if (lit is StringLiteral) {
							set_cname (((StringLiteral) lit).eval ());
						}
					}
				} else if (arg.name == "cprefix") {
					/* this will already be checked during semantic analysis */
					if (arg.argument is LiteralExpression) {
						var lit = ((LiteralExpression) arg.argument).literal;
						if (lit is StringLiteral) {
							set_cprefix (((StringLiteral) lit).eval ());
						}
					}
				} else if (arg.name == "cheader_filename") {
					/* this will already be checked during semantic analysis */
					if (arg.argument is LiteralExpression) {
						var lit = ((LiteralExpression) arg.argument).literal;
						if (lit is StringLiteral) {
							var val = ((StringLiteral) lit).eval ();
							foreach (string filename in val.split (",", 0)) {
								cheader_filenames.append (filename);
							}
						}
					}
				}
			}
		}
		
		public void process_attributes () {
			foreach (Attribute a in attributes) {
				if (a.name == "CCode") {
					process_ccode_attribute (a);
				}
			}
		}
	}
}
