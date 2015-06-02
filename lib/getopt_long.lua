local ffi = require("ffi")
local stringz = require("stringz")

--[[
#include <config.h>
#include <errno.h>

#include "util.h"
#include "openvswitch/vlog.h"
--]]

--VLOG_DEFINE_THIS_MODULE(getopt_long);

local int	opterr = 1;		/* if error message should be printed */
local int	optind = 1;		/* index into parent argv vector */
local int	optopt = '?';		/* character checked for validity */
local int	optreset = 0;		/* reset getopt */
local char    *optarg;		/* argument associated with option */

#define IGNORE_FIRST	(*options == '-' || *options == '+')
#define PRINT_ERROR	((opterr) && ((*options != ':') \
				      || (IGNORE_FIRST && options[1] != ':')))
#define IS_POSIXLY_CORRECT (getenv("POSIXLY_CORRECT") != NULL)
#define PERMUTE         (!IS_POSIXLY_CORRECT && !IGNORE_FIRST)
/* XXX: GNU ignores PC if *options == '-' */
#define IN_ORDER        (!IS_POSIXLY_CORRECT && *options == '-')

-- return values
local BADCH	= string.byte('?')
#define	BADARG		((IGNORE_FIRST && options[1] == ':') \
			 || (*options == ':') ? (int)':' : (int)'?')
local INORDER = 1;

local EMSG	= "";

local function _DIAGASSERT(q) 
	return ovs_assert(q)
end

local warnx = VLOG_WARN


local place = EMSG; -- option letter processing */

-- XXX: set optreset to 1 rather than these two */
local nonopt_start = -1; -- first non option argument (for permute) */
local nonopt_end = -1;   -- first option after non options (for permute) */

-- Error messages */
local recargchar[] = "option requires an argument -- %c";
local recargstring[] = "option requires an argument -- %s";
local ambig[] = "ambiguous option -- %.*s";
local noarg[] = "option doesn't take an argument -- %.*s";
local illoptchar[] = "unknown option -- %c";
local illoptstring[] = "unknown option -- %s";



-- * Compute the greatest common divisor of a and b.

local function gcd(a, b)
	int c;

	local c = a % b;
	while (c ~= 0) do
		a = b;
		b = c;
		c = a % b;
	end

	return b;
end

--[[
/*
 * Exchange the block from nonopt_start to nonopt_end with the block
 * from nonopt_end to opt_end (keeping the same order of arguments
 * in each block).
 */
--]]

local function permute_args(int panonopt_start, int panonopt_end, int opt_end, char **nargv)

	_DIAGASSERT(nargv ~= nil);

	-- compute lengths of blocks and number and size of cycles
	local nnonopts = panonopt_end - panonopt_start;
	local nopts = opt_end - panonopt_end;
	local ncycle = gcd(nnonopts, nopts);
	local cyclelen = (opt_end - panonopt_start) / ncycle;

	for i = 0, ncycle-1 do
		local cstart = panonopt_end+i;
		local pos = cstart;
		for j = 0, cyclelen-1 do
			if (pos >= panonopt_end) then
				pos = pos - nnonopts;
			else
				pos = pos + nopts;
			end
			local swap = nargv[pos];
			nargv[pos] = nargv[cstart];
			nargv[cstart] = swap;
		end
	end
end

--[[
/*
 * getopt_internal --
 *	Parse argc/argv argument vector.  Called by user level routines.
 *  Returns -2 if -- is found (can be long option or end of options marker).
 */
--]]

local function getopt_internal(int nargc, char **nargv, const char *options)

	char *oli;				/* option letter list index */
	int optchar;

	_DIAGASSERT(nargv != NULL);
	_DIAGASSERT(options != NULL);

	optarg = NULL;

	/*
	 * XXX Some programs (like rsyncd) expect to be able to
	 * XXX re-initialize optind to 0 and have getopt_long(3)
	 * XXX properly function again.  Work around this braindamage.
	 */
	if (optind == 0)
		optind = 1;

	if (optreset)
		nonopt_start = nonopt_end = -1;
start:
	if (optreset || !*place) {		/* update scanning pointer */
		optreset = 0;
		if (optind >= nargc) {          /* end of argument vector */
			place = EMSG;
			if (nonopt_end != -1) {
				/* do permutation, if we have to */
				permute_args(nonopt_start, nonopt_end,
				    optind, nargv);
				optind -= nonopt_end - nonopt_start;
			}
			else if (nonopt_start != -1) {
				/*
				 * If we skipped non-options, set optind
				 * to the first of them.
				 */
				optind = nonopt_start;
			}
			nonopt_start = nonopt_end = -1;
			return -1;
		}
		if ((*(place = nargv[optind]) != '-')
		    || (place[1] == '\0')) {    /* found non-option */
			place = EMSG;
			if (IN_ORDER) {
				/*
				 * GNU extension:
				 * return non-option as argument to option 1
				 */
				optarg = nargv[optind++];
				return INORDER;
			}
			if (!PERMUTE) {
				/*
				 * if no permutation wanted, stop parsing
				 * at first non-option
				 */
				return -1;
			}
			/* do permutation */
			if (nonopt_start == -1)
				nonopt_start = optind;
			else if (nonopt_end != -1) {
				permute_args(nonopt_start, nonopt_end,
				    optind, nargv);
				nonopt_start = optind -
				    (nonopt_end - nonopt_start);
				nonopt_end = -1;
			}
			optind++;
			/* process next argument */
			goto start;
		}
		if (nonopt_start != -1 && nonopt_end == -1)
			nonopt_end = optind;
		if (place[1] && *++place == '-') {	/* found "--" */
			place++;
			return -2;
		}
	}
	if ((optchar = (int)*place++) == (int)':' ||
	    (oli = strchr(options + (IGNORE_FIRST ? 1 : 0), optchar)) == NULL) {
		/* option letter unknown or ':' */
		if (!*place)
			++optind;
		if (PRINT_ERROR)
			warnx(illoptchar, optchar);
		optopt = optchar;
		return BADCH;
	}
	if (optchar == 'W' && oli[1] == ';') {		/* -W long-option */
		/* XXX: what if no long options provided (called by getopt)? */
		if (*place)
			return -2;

		if (++optind >= nargc) {	/* no arg */
			place = EMSG;
			if (PRINT_ERROR)
				warnx(recargchar, optchar);
			optopt = optchar;
			return BADARG;
		} else				/* white space */
			place = nargv[optind];
		/*
		 * Handle -W arg the same as --arg (which causes getopt to
		 * stop parsing).
		 */
		return -2;
	}
	if (*++oli != ':') {			/* doesn't take argument */
		if (!*place)
			++optind;
	} else {				/* takes (optional) argument */
		optarg = NULL;
		if (*place)			/* no white space */
			optarg = CONST_CAST(char *, place);
		/* XXX: disable test for :: if PC? (GNU doesn't) */
		else if (oli[1] != ':') {	/* arg not optional */
			if (++optind >= nargc) {	/* no arg */
				place = EMSG;
				if (PRINT_ERROR)
					warnx(recargchar, optchar);
				optopt = optchar;
				return BADARG;
			} else
				optarg = nargv[optind];
		}
		place = EMSG;
		++optind;
	}
	/* dump back option letter */
	return optchar;
end

--[[
/*
 * getopt --
 *	Parse argc/argv argument vector.
 *
 * [eventually this will replace the real getopt]
 */
--]]
local getopt(nargc, nargv, options)

	int retval;

	_DIAGASSERT(nargv ~= nil);
	_DIAGASSERT(options ~= nil);

    retval = getopt_internal(nargc, CONST_CAST(char **, nargv), options);
	if (retval == -2) then
		optind = optind + 1;
		--[[
		/*
		 * We found an option (--), so if we skipped non-options,
		 * we have to permute.
		 */
		 --]]
		if (nonopt_end ~= -1) then
			permute_args(nonopt_start, nonopt_end, optind, nargv);
			optind = optind - nonopt_end - nonopt_start;
		end
		nonopt_start = -1;
		nonopt_end = -1;
		retval = -1;
	end

	return retval;
end

--[[
/*
 * getopt_long --
 *	Parse argc/argv argument vector.
 */
--]]

local function getopt_long(int nargc, char * const *nargv, const char *options,
    const struct option *long_options, int *idx)

	local function IDENTICAL_INTERPRETATION(_x, _y)				
		return (long_options[_x].has_arg == long_options[_y].has_arg and	
	 		long_options[_x].flag == long_options[_y].flag and		
	 		long_options[_x].val == long_options[_y].val)
	end

	_DIAGASSERT(nargv != nil);
	_DIAGASSERT(options != nil);
	_DIAGASSERT(long_options != nil);
	-- idx may be NULL */

    local retval = getopt_internal(nargc, CONST_CAST(char **, nargv), options);
	if (retval == -2) then
		char *current_argv, *has_equal;
		size_t current_argv_len;
		int i;

        local current_argv = CONST_CAST(char *, place);
		local match = -1;
		local ambiguous = 0;

		optind = optind + 1;
		place = EMSG;

		if (*current_argv == '\0') then		-- found "--" 
			--[[
			/*
			 * We found an option (--), so if we skipped
			 * non-options, we have to permute.
			 */
			--]]
			if (nonopt_end != -1) then
				permute_args(nonopt_start, nonopt_end,
                    optind, CONST_CAST(char **, nargv));
				optind -= nonopt_end - nonopt_start;
			end
			nonopt_start = nonopt_end = -1;
			
			return -1;
		end

		if ((has_equal = stringz.strchr(current_argv, '=')) ~= nil) then
			-- argument found (--option=arg) */
			current_argv_len = has_equal - current_argv;
			has_equal++;
		else
			current_argv_len = strlen(current_argv);
		end

		for (i = 0; long_options[i].name; i++) {
			/* find matching long option */
			if (strncmp(current_argv, long_options[i].name,
			    current_argv_len))
				continue;

			if (strlen(long_options[i].name) ==
			    (unsigned)current_argv_len) {
				/* exact match */
				match = i;
				ambiguous = 0;
				break;
			}
			if (match == -1)		/* partial match */
				match = i;
			else if (!IDENTICAL_INTERPRETATION(i, match))
				ambiguous = 1;
		}
		if (ambiguous) {
			/* ambiguous abbreviation */
			if (PRINT_ERROR)
				warnx(ambig, (int)current_argv_len,
				     current_argv);
			optopt = 0;
			return BADCH;
		}
		if (match != -1) then			-- option found
		    if (long_options[match].has_arg == no_argument and has_equal) 
		    {
				if (PRINT_ERROR)
					warnx(noarg, (int)current_argv_len,
					     current_argv);
				/*
				 * XXX: GNU sets optopt to val regardless of
				 * flag
				 */
				if (long_options[match].flag == NULL)
					optopt = long_options[match].val;
				else
					optopt = 0;
				return BADARG;
			}
			
			if (long_options[match].has_arg == required_argument or
			    long_options[match].has_arg == optional_argument) then
				if (has_equal)
					optarg = has_equal;
				elseif (long_options[match].has_arg == required_argument) then
					--[[
					/*
					 * optional argument doesn't use
					 * next nargv
					 */
					--]]
					optarg = nargv[optind];
					optind = optind + 1;
				end
			end

			if ((long_options[match].has_arg == required_argument)
			    && (optarg == NULL)) {
				/*
				 * Missing argument; leading ':'
				 * indicates no error should be generated
				 */
				if (PRINT_ERROR)
					warnx(recargstring, current_argv);
				/*
				 * XXX: GNU sets optopt to val regardless
				 * of flag
				 */
				if (long_options[match].flag == NULL)
					optopt = long_options[match].val;
				else
					optopt = 0;
				--optind;
				return BADARG;
			}
		else 			/* unknown option */
			if (PRINT_ERROR)
				warnx(illoptstring, current_argv);
			optopt = 0;
			return BADCH;
		end

		if (long_options[match].flag) then
			*long_options[match].flag = long_options[match].val;
			retval = 0;
		else
			retval = long_options[match].val;
		end

		if (idx ~= nil) then
			idx[0] = match;
		end
	end

	return retval;
end


local exports = {
	getopt = getopt;
	getopt_long = getopt_long;
}