local ffi = require("ffi")

-- Doubly linked list. */


--require ("util")
require ("ovs.openvswitch.ovs_list")

--[[
static inline void list_init(struct ovs_list *);
static inline void list_poison(struct ovs_list *);

/* List insertion. */
static inline void list_insert(struct ovs_list *, struct ovs_list *);
static inline void list_splice(struct ovs_list *before, struct ovs_list *first,
                               struct ovs_list *last);
static inline void list_push_front(struct ovs_list *, struct ovs_list *);
static inline void list_push_back(struct ovs_list *, struct ovs_list *);
static inline void list_replace(struct ovs_list *, const struct ovs_list *);
static inline void list_moved(struct ovs_list *, const struct ovs_list *orig);
static inline void list_move(struct ovs_list *dst, struct ovs_list *src);

/* List removal. */
static inline struct ovs_list *list_remove(struct ovs_list *);
static inline struct ovs_list *list_pop_front(struct ovs_list *);
static inline struct ovs_list *list_pop_back(struct ovs_list *);

/* List elements. */
static inline struct ovs_list *list_front(const struct ovs_list *);
static inline struct ovs_list *list_back(const struct ovs_list *);

/* List properties. */
static inline size_t list_size(const struct ovs_list *);
static inline bool list_is_empty(const struct ovs_list *);
static inline bool list_is_singleton(const struct ovs_list *);
static inline bool list_is_short(const struct ovs_list *);
--]]

--[[
#define LIST_FOR_EACH(ITER, MEMBER, LIST)                               \
    for (INIT_CONTAINER(ITER, (LIST)->next, MEMBER);                    \
         &(ITER)->MEMBER != (LIST);                                     \
         ASSIGN_CONTAINER(ITER, (ITER)->MEMBER.next, MEMBER))
#define LIST_FOR_EACH_CONTINUE(ITER, MEMBER, LIST)                      \
    for (INIT_CONTAINER(ITER, (ITER)->MEMBER.next, MEMBER);             \
         &(ITER)->MEMBER != (LIST);                                     \
         ASSIGN_CONTAINER(ITER, (ITER)->MEMBER.next, MEMBER))
#define LIST_FOR_EACH_REVERSE(ITER, MEMBER, LIST)                       \
    for (INIT_CONTAINER(ITER, (LIST)->prev, MEMBER);                    \
         &(ITER)->MEMBER != (LIST);                                     \
         ASSIGN_CONTAINER(ITER, (ITER)->MEMBER.prev, MEMBER))
#define LIST_FOR_EACH_REVERSE_CONTINUE(ITER, MEMBER, LIST)              \
    for (ASSIGN_CONTAINER(ITER, (ITER)->MEMBER.prev, MEMBER);           \
         &(ITER)->MEMBER != (LIST);                                     \
         ASSIGN_CONTAINER(ITER, (ITER)->MEMBER.prev, MEMBER))
#define LIST_FOR_EACH_SAFE(ITER, NEXT, MEMBER, LIST)               \
    for (INIT_CONTAINER(ITER, (LIST)->next, MEMBER);               \
         (&(ITER)->MEMBER != (LIST)                                \
          ? INIT_CONTAINER(NEXT, (ITER)->MEMBER.next, MEMBER), 1   \
          : 0);                                                    \
         (ITER) = (NEXT))
#define LIST_FOR_EACH_POP(ITER, MEMBER, LIST)                      \
    while (!list_is_empty(LIST)                                    \
           && (INIT_CONTAINER(ITER, list_pop_front(LIST), MEMBER), 1))
--]]



--/* Initializes 'list' as an empty list. */
--static inline void
local function list_init(list)
    list.next = list;
    list.prev = list;
end


--/* Initializes 'list' with pointers that will (probably) cause segfaults if
-- * dereferenced and, better yet, show up clearly in a debugger. */
--static inline void
local function list_poison(list)
    ffi.fill(list, ffi.sizeof("struct ovs_list"), 0xcc);
end


--/* Inserts 'elem' just before 'before'. */
--static inline void
local function list_insert(before, elem)
    elem.prev = before.prev;
    elem.next = before;
    before.prev.next = elem;
    before.prev = elem;
end

--/* Removes elements 'first' though 'last' (exclusive) from their current list,
--   then inserts them just before 'before'. */
--static inline void
local function list_splice(before, first, last)
    if (first == last) then
        return;
    end
    last = last.prev;

    -- Cleanly remove 'first'...'last' from its current list. */
    first.prev.next = last.next;
    last.next.prev = first.prev;

    -- Splice 'first'...'last' into new list. */
    first.prev = before.prev;
    last.next = before;
    before.prev.next = first;
    before.prev = last;
end

--/* Inserts 'elem' at the beginning of 'list', so that it becomes the front in
--   'list'. */
--static inline void
local function list_push_front(list, elem)
    list_insert(list.next, elem);
end

--/* Inserts 'elem' at the end of 'list', so that it becomes the back in
-- * 'list'. */
--static inline void
local function list_push_back(list, elem)
    list_insert(list, elem);
end

--/* Puts 'elem' in the position currently occupied by 'position'.
-- * Afterward, 'position' is not part of a list. */
--static inline void
local function list_replace(element, position)
    element.next = position.next;
    element.next.prev = element;
    element.prev = position.prev;
    element.prev.next = element;
end

--[=[
--[[
/* Adjusts pointers around 'list' to compensate for 'list' having been moved
 * around in memory (e.g. as a consequence of realloc()), with original
 * location 'orig'.
 *
 * ('orig' likely points to freed memory, but this function does not
 * dereference 'orig', it only compares it to 'list'.  In a very pedantic
 * language lawyer sense, this still yields undefined behavior, but it works
 * with actual compilers.) */
--]]
--static inline void
local function list_moved(struct ovs_list *list, const struct ovs_list *orig)

    if (list->next == orig) {
        list_init(list);
    } else {
        list->prev->next = list->next->prev = list;
    }
end

--/* Initializes 'dst' with the contents of 'src', compensating for moving it
-- * around in memory.  The effect is that, if 'src' was the head of a list, now
-- * 'dst' is the head of a list containing the same elements. */
--static inline void
local function list_move(struct ovs_list *dst, struct ovs_list *src)

    *dst = *src;
    list_moved(dst, src);
end

--/* Removes 'elem' from its list and returns the element that followed it.
--   Undefined behavior if 'elem' is not in a list. */
--static inline struct ovs_list *
local function list_remove(struct ovs_list *elem)

    elem->prev->next = elem->next;
    elem->next->prev = elem->prev;
    return elem->next;
end

--/* Removes the front element from 'list' and returns it.  Undefined behavior if
--   'list' is empty before removal. */
--static inline struct ovs_list *
local function list_pop_front(struct ovs_list *list)

    struct ovs_list *front = list->next;

    list_remove(front);
    return front;
end

--/* Removes the back element from 'list' and returns it.
--   Undefined behavior if 'list' is empty before removal. */
--static inline struct ovs_list *
local function list_pop_back(struct ovs_list *list)

    struct ovs_list *back = list->prev;

    list_remove(back);
    return back;
end

--/* Returns the front element in 'list_'.
--   Undefined behavior if 'list_' is empty. */
--static inline struct ovs_list *
local function list_front(const struct ovs_list *list_)

    struct ovs_list *list = CONST_CAST(struct ovs_list *, list_);

    ovs_assert(!list_is_empty(list));

    return list->next;
end

-- /* Returns the back element in 'list_'.
--   Undefined behavior if 'list_' is empty. */
--static inline struct ovs_list *
local function list_back(const struct ovs_list *list_)

    struct ovs_list *list = CONST_CAST(struct ovs_list *, list_);

    ovs_assert(!list_is_empty(list));

    return list->prev;
end

--/* Returns the number of elements in 'list'.
--   Runs in O(n) in the number of elements. */
--static inline size_t
local function list_size(const struct ovs_list *list)

    const struct ovs_list *e;
    size_t cnt = 0;

    for (e = list->next; e != list; e = e->next) {
        cnt++;
    }
    return cnt;
end
--]=]

--/* Returns true if 'list' is empty, false otherwise. */
--static inline bool
local function list_is_empty(list)
    return list.next == list;
end

--/* Returns true if 'list' has exactly 1 element, false otherwise. */
--static inline bool
local function list_is_singleton(list)
    return list_is_short(list) and not list_is_empty(list);
end

--/* Returns true if 'list' has 0 or 1 elements, false otherwise. */
--static inline bool
local function list_is_short(list)
    return list.next == list.prev;
end

