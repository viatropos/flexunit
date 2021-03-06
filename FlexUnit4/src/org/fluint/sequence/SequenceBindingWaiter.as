/**
 * Copyright (c) 2007 Digital Primates IT Consulting Group
 * 
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 **/ 
package org.fluint.sequence {
	import flash.events.IEventDispatcher;
	
	import mx.binding.utils.ChangeWatcher;
	import mx.events.PropertyChangeEvent;
	
	import org.flexunit.async.AsyncLocator;
	import org.flexunit.internals.runners.statements.IAsyncHandlingStatement;
	
	/** 
	 * The sequence setter class tells the TestCase instance to pend until 
	 * the eventName occurs or the timeout expires.
	 */	 
	public class SequenceBindingWaiter implements ISequencePend {
        /**
         * @private
         */
		protected var _target:IEventDispatcher;

        /**
         * @private
         */
		protected var _eventName:String;

        /**
         * @private
         */
		protected var _propertyName:String;

        /**
         * @private
         */
		protected var _timeout:int;
		
		protected var _cw:ChangeWatcher;

        /**
         * @private
         */
		protected var _timeoutHandler:Function;

		public function get changeWatcher():ChangeWatcher {
			return _cw;	
		}

		/** 
		 * The event dispatcher where the properties/value pairs defined 
		 * in the props object will be set. 
		 */
		public function get target():IEventDispatcher {
			return _target;	
		}

		/** 
		 * Name of the event that will be broadcast by the target. 
		 * 
		 * When this event is broadcast, the TestCase sequence
		 * code moves onto the next step in the sequence. 
		 */
		public function get eventName():String {
			return _eventName;
		}

		/** 
		 * Name of the property that will change. 
		 * 
		 * When this property changes, the TestCase sequence
		 * code moves onto the next step in the sequence. 
		 */
		public function get propertyName():String {
			return _propertyName;
		}

		/** 
		 * The number of milliseconds this class should wait for its handleEvent 
		 * method to be called, before firing a 'timerExpired' event. 
		 */
		public function get timeout():int {
			return _timeout;
		}

		/** 
		 * A reference to the event handler that should be called if the event named in eventName  
		 * does not fire before the timeout is reached. The handler is expected to have the follow signature:
		 * 
		 * public function handleTimeoutEvent( passThroughData:Object ):void {
		 * }
		 * 
		 * The parameter is a generic object that can optionally be provided by the developer when starting
		 * a new asynchronous operation.
		 */
		public function get timeoutHandler():Function {
			return _timeoutHandler;
		}

		/** 
		 * Called by the SequenceRunner to cause the setup of event listeners
		 * 
		 * @throws Error Attempting to watch un-watchable property
		 **/ 
		public function setupListeners( testCase:*, sequence:SequenceRunner ):void {
			if ( ChangeWatcher.canWatch( target, propertyName ) ) {
				var asyncHandlingStatement:IAsyncHandlingStatement = AsyncLocator.getCallableForTest( testCase );
				_cw = ChangeWatcher.watch( target, propertyName, asyncHandlingStatement.asyncHandler( asyncHandlingStatement.handleBindableNextSequence, timeout, sequence, timeoutHandler ) );
			} else {
				throw new Error( "Attempting to watch un-watchable property" );
			}
			//target.addEventListener( PropertyChangeEvent.PROPERTY_CHANGE, testCase.asyncHandler( testCase.handleBindableNextSequence, timeout, sequence, timeoutHandler ), false, 0, true );
		}
		/**
		 * Constructor.
		 *  
		 * @param target The target where the property exists.
		 * @param propertyName The name of the property that will change via data binding.
		 * @param timeout The number of milliseconds to wait before calling the timoutHandler.
		 * @param timeoutHandler Called if the timout is reached before the event is broadcast. 
		 */
		public function SequenceBindingWaiter( target:IEventDispatcher, propertyName:String, timeout:int, timeoutHandler : Function = null  ) {
			_target = target;
			_propertyName = propertyName;
			_eventName = PropertyChangeEvent.PROPERTY_CHANGE;
			
			_timeoutHandler = timeoutHandler;
			_timeout = timeout;
		}
	}
}