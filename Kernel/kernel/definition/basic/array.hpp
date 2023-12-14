#pragma once

#include "kernel/definition/library.hpp"
#include "kernel/definition/assert.hpp"
#include "kernel/definition/macro.hpp"

namespace Sen::Kernel {

	/**
	 * Array class: Only for static array
	*/

	template <class T, std::size_t n_size> 
	class Array {

		public:

			std::array<T, n_size> value;

			// constructor

			Array(

			) : value{}
			{

			}

			// destructor

			~Array(

			) = default;

			// fill
			
			auto fill(
				T value
			) -> void
			{
				for(auto i : Range<size_t>(thiz.value.size())){
					thiz[i] = value;
				}
				return;
			}

			// constructor

			Array(
				const Array & that
			) : Array{}
			{
				std::copy(that.begin(), that.end(), thiz.value.begin());
			}

			// constructor

			Array(
				std::initializer_list<T> iArray
			) 
			{
				for (auto i : Range<size_t>(iArray)) {
					thiz[i] = iArray[i];
				}
			}

			// begin

			auto begin(

			) -> decltype(value.begin())
			{
				return thiz.value.begin();
			}

			// end

			auto end(

			) -> decltype(value.end())
			{
				return thiz.value.end();
			}

			// operator []

			auto operator [](
				size_t index
			) -> T&
			{
				return thiz.value.at(index);
			}

			// operator =

			auto operator =(
				Array & that
			) -> Array
			{
				auto new_array = Array<T, that.value.size()>{};
				std::copy(that.begin(), that.end(), new_array.value.begin());
				return new_array;
			}

			// size

			auto size(

			) -> size_t
			{
				return thiz.value.size();
			}

			// operator ==

			auto operator ==(
				Array & that
			) -> bool
			{
				if(thiz.size() != that.size()){
					return false;
				}
				for(auto i : Range<size_t>(that)){
					if(that[i] != thiz[i]){
						return false;
					}
				}
				return true;
			}

			// operator !=

			auto operator !=(
				Array & that
			) -> bool
			{
				return !(thiz == that);
			}

			// for each
			
			auto forEach(
				std::function<void(T& e, size_t i)> method
			) -> void
			{
				for(auto i : Range<size_t>(thiz.value)){
					method(thiz[i], i);
				}
				return;
			}

			// for each

			auto forEach(
				std::function<void(T& e)> method
			) -> void
			{
				for(auto & c : thiz.value){
					method(c);
				}
				return;
			}

			// map

			template <typename P, size_t Sz>
			auto map(
				std::function<P(T& e)> method
			) -> Array<P, Sz>
			{
				auto arr = Array<P, Sz>{};
				for(auto i : Range<size_t>(thiz.value)){
					arr[i] = method(thiz[i]);
				}
				return arr;
			}

			
			// map

			template <typename P, size_t Sz>
			auto map(
				std::function<P(T& e, size_t index)> method
			) -> Array<P, Sz>
			{
				auto arr = Array<P, Sz>{};
				for(auto i : Range<size_t>(thiz.value)){
					arr[i] = method(thiz[i], i);
				}
				return arr;
			}

			/**
			 * every
			*/

			auto every(
				std::function<bool(T& e)> method
			) -> bool
			{
				for(auto & c : thiz){
					if(!method(c)){
						return false;
					}
				}
				return true;
			}

			/**
			 * every
			*/

			auto every(
				std::function<bool(T& e, size_t index)> method
			) -> bool
			{
				for(auto & i : Range<size_t>(thiz)){
					if(!method(thiz[i], i)){
						return false;
					}
				}
				return true;
			}

			/**
			 * Sort method
			*/

			template <typename P>
			auto sort(
				std::function<P(T& a, T& b)> method
			) -> void
			{
				std::sort(thiz.begin(), thiz.end(), method);
				return;
			}

			/**
			 * some
			*/

			auto some(
				std::function<bool(T& e)> method
			) -> bool
			{
				for(auto & c : thiz){
					if(method(c)){
						return true;
					}
				}
				return false;
			}

			/**
			 * some
			*/

			auto some(
				std::function<bool(T& e, size_t index)> method
			) -> bool
			{
				for(auto i : Range<size_t>(thiz)){
					if(method(thiz[i], i)){
						return true;
					}
				}
				return false;
			}
	};
}