# Bridge.lua
Bridge.lua is a C#-to-Lua Compiler,which generates equivalent and consistent lua code, it will do some optimizations, such as local optimization, constant conversion, etc. Based on modified from [bridge.net](https://github.com/bridgedotnet/Bridge)


## Sample

The following c# code that implements timer management, reference [folly‘s TimeoutQueue](https://github.com/facebook/folly/blob/master/folly/TimeoutQueue.h)

```csharp
using System;
using System.Collections.Generic;
using System.Linq;

namespace Ice.Utils {
    public sealed class TimeoutQueue {
        private sealed class Event {
            public int Id;
            public Int64 Expiration;
            public Int64 RepeatInterval;
            public Action<int, Int64> Callback;
            public LinkedListNode<Event> LinkNode;
        }

        private int nextId_ = 1;
        private Dictionary<int, Event> ids_ = new Dictionary<int, Event>();
        private LinkedList<Event> events_ = new LinkedList<Event>();

        private int NextId {
            get { return nextId_++; }
        }

        private void Insert(Event e) {
            ids_.Add(e.Id, e);
            Event next = events_.FirstOrDefault(i => i.Expiration > e.Expiration);
            if(next != null) {
                e.LinkNode = events_.AddBefore(next.LinkNode, e);
            } else {
                e.LinkNode = events_.AddLast(e);
            }
        }

        public int Add(Int64 now, Int64 delay, Action<int, Int64> callback) {
            return AddRepeating(now, delay, 0, callback);
        }

        public int AddRepeating(Int64 now, Int64 interval, Action<int, Int64> callback) {
            return AddRepeating(now, interval, interval, callback);
        }

        public int AddRepeating(Int64 now, Int64 delay, Int64 interval, Action<int, Int64> callback) {
            int id = NextId;
            Insert(new Event() {
                Id = id,
                Expiration = now + delay,
                RepeatInterval = interval,
                Callback = callback
            });
            return id;
        }

        public Int64 NextExpiration {
            get {
                return events_.Count > 0 ? events_.First.Value.Expiration : Int64.MaxValue;
            }
        }

        public bool Erase(int id) {
            Event e;
            if(ids_.TryGetValue(id, out e)) {
                ids_.Remove(id);
                events_.Remove(e.LinkNode);
                return true;
            }
            return false;
        }

        public Int64 RunOnce(Int64 now) {
            return RunInternal(now, true);
        }

        public Int64 RunLoop(Int64 now) {
            return RunInternal(now, false);
        }

        public bool IsEmpty {
            get {
                return ids_.Count == 0;
            }
        }

        public bool Contains(int id) {
            return ids_.ContainsKey(id);
        }

        private Int64 RunInternal(Int64 now, bool onceOnly) {
            Int64 nextExp;
            do {
                List<Event> expired = events_.TakeWhile(i => i.Expiration <= now).ToList();
                foreach(Event e in expired) {
                    Erase(e.Id);
                    if(e.RepeatInterval > 0) {
                        e.Expiration += e.RepeatInterval;
                        Insert(e);
                    }
                }
                foreach(Event e in expired) {
                    e.Callback(e.Id, now);
                }
                nextExp = NextExpiration;
            } while(!onceOnly && nextExp <= now);
            return nextExp;
        }
    }
}
```
You will get the equivalent, the possibility of a good lua code.
```lua
local System = System
local IceUtilsTimeoutQueue

System.usingDeclare(function()
    IceUtilsTimeoutQueue = Ice.Utils.TimeoutQueue
end)

System.namespace("Ice.Utils", function(namespace)
    namespace.class("TimeoutQueue", function ()
        local getNextId, getNextExpiration, getIsEmpty, insert, add, addRepeating, addRepeating_1, erase
        local runOnce, runLoop, contains, runInternal
        local __init__, __ctor1__
        __init__ = function (this) 
            this.ids_ = System.Dictionary(System.Int, IceUtilsTimeoutQueue.Event)()
            this.events_ = System.LinkedList(IceUtilsTimeoutQueue.Event)()
        end
        __ctor1__ = function (this) 
            __init__(this)
        end
        getNextId = function (this) 
            local __t__
            __t__ = this.nextId_
            this.nextId_ = this.nextId_ + 1
            return __t__
        end
        getNextExpiration = function (this) 
            return System.ternary(#this.events_ > 0, this.events_:getFirst().value.expiration, 9007199254740991)
        end
        getIsEmpty = function (this) 
            return this.ids_:getCount() == 0
        end
        insert = function (this, e) 
            this.ids_:add(e.id, e)
            local next = System.Linq(this.events_):firstOrDefault(function (i) 
                return i.expiration > e.expiration
            end)
            if next ~= nil then
                e.linkNode = this.events_:addBefore(next.linkNode, e)
            else
                e.linkNode = this.events_:addLast(e)
            end
        end
        add = function (this, now, delay, callback) 
            return addRepeating_1(this, now, delay, 0, callback)
        end
        addRepeating = function (this, now, interval, callback) 
            return addRepeating_1(this, now, interval, interval, callback)
        end
        addRepeating_1 = function (this, now, delay, interval, callback) 
            local id = getNextId(this)
            insert(this, System.merge(IceUtilsTimeoutQueue.Event(), function (t)
                t.id = id
                t.expiration = now + delay
                t.repeatInterval = interval
                t.callback = callback
            end))
            return id
        end
        erase = function (this, id) 
            local __t__
            local e
            __t__, e = this.ids_:tryGetValue(id, e)
            if __t__ then
                this.ids_:remove(id)
                this.events_:remove(e.linkNode)
                return true
            end
            return false
        end
        runOnce = function (this, now) 
            return runInternal(this, now, true)
        end
        runLoop = function (this, now) 
            return runInternal(this, now, false)
        end
        contains = function (this, id) 
            return this.ids_:containsKey(id)
        end
        runInternal = function (this, now, onceOnly) 
            local nextExp
            repeat 
                local expired = System.Linq(this.events_):takeWhile(function (i) 
                    return i.expiration <= now
                end):toList()
                for _, e in System.each(expired) do
                    erase(this, e.id)
                    if e.repeatInterval > 0 then
                        e.expiration = e.expiration + e.repeatInterval
                        insert(this, e)
                    end
                end
                for _, e in System.each(expired) do
                    e.callback(e.id, now)
                end
                nextExp = getNextExpiration(this)
            until not(not onceOnly and nextExp <= now)
            return nextExp
        end
        return {
            nextId_ = 1,
            __ctor__ = __ctor1__,
            getNextExpiration = getNextExpiration,
            getIsEmpty = getIsEmpty,
            add = add,
            addRepeating = addRepeating,
            addRepeating_1 = addRepeating_1,
            erase = erase,
            runOnce = runOnce,
            runLoop = runLoop,
            contains = contains
        }
    end)
    namespace.class("TimeoutQueue.Event", function ()
        local __init__, __ctor1__
        __init__ = function (this) 
            this.expiration = 0
            this.repeatInterval = 0
        end
        __ctor1__ = function (this) 
            __init__(this)
        end
        return {
            id = 0,
            callback = nil,
            linkNode = nil,
            __ctor__ = __ctor1__
        }
    end)
end)
```

## How to Use
###Command Line Parameters
```cmd
D:\bridge>Bridge.Lua.exe -h
Usage: Bridge.Lua [-f srcfolder] [-p outfolder]
Arguments 
-f              : intput directory, all *.cs files whill be compiled
-p              : out directory, will put the out lua files

Options
-b [option]     : the path of bridge.all, defalut will use bridge.all under the same directory of Bridge.Lua.exe
-l [option]     : third-party libraries referenced, use ';' to separate
-lb [option]    : blacklist of third-party libraries, use ';' to separate,
                  E.g '#System.Collections;System.Text.StringBuilder', except class named System.Text.StringBuilder, namespace named System.Collections
-lw [option]    : whitelist of third-party libraries, use ';' to separate         
```
###Download
[bridge.lua.1.0.1.zip](https://raw.githubusercontent.com/sy-yanghuan/bridge.lua/master/download/bridge.lua.1.0.1.zip)

## CoreSystem.lua
[CoreSystem.lua library](https://github.com/sy-yanghuan/bridge.lua/tree/master/Compiler/Lua/CoreSystem.Lua/CoreSystem) that implements most of the [.net framework core classes](http://referencesource.microsoft.com/), including support for basic type, delegate, generic collection classes & linq. The Converted lua code, need to reference it  
- Download [CoreSysrem.lua.zip](https://raw.githubusercontent.com/sy-yanghuan/bridge.lua/master/download/CoreSystem.lua.zip)

##Example
- [fibonacci](https://github.com/sy-yanghuan/bridge.lua/tree/master/Example/fibonacci), a console program code, print Fibonacci number. 

## Documentation
- Documentation Home [English](https://github.com/sy-yanghuan/bridge.lua/wiki/English-Home-Page) [Chinese](https://github.com/sy-yanghuan/bridge.lua/wiki/%E4%B8%AD%E6%96%87%E6%96%87%E6%A1%A3)
- FAQ [English](https://github.com/sy-yanghuan/bridge.lua/wiki/FAQ) [Chinese](https://github.com/sy-yanghuan/bridge.lua/wiki/%E5%B8%B8%E8%A7%81%E9%97%AE%E9%A2%98%E8%A7%A3%E7%AD%94)

##License
Bridge.lua is released under the [Apache 2.0 license](LICENSE).

##*Thanks*
[http://bridge.net](http://bridge.net )

