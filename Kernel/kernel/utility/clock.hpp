#pragma once

#include <chrono>

namespace Sen::Kernel {

	struct Clock {

		explicit Clock(
		) : start_time_{}, duration_{ 0 }, running_{ false } {
		}

		~Clock(

		) = default;

		inline auto start_safe(

		) -> void
		{
			if (!running_) {
				start_time_ = std::chrono::steady_clock::now();
				running_ = true;
			}
		}

		inline auto stop_safe(

		) -> void
		{
			if (running_) {
				auto end_time = std::chrono::steady_clock::now();
				duration_ += std::chrono::duration_cast<std::chrono::milliseconds>(end_time - start_time_).count();
				running_ = false;
			}
		}

		inline auto reset(

		) -> void
		{
			duration_ = 0;
			running_ = false;
		}

		inline auto get_duration(

		) -> int64_t
		{
			return duration_;
		}

		inline auto is_started(

		) -> bool
		{
			return running_;
		}

		inline auto is_stopped(

		) -> bool
		{
			return !running_;
		}

	private:
		std::chrono::time_point<std::chrono::steady_clock> start_time_;
		int64_t duration_;
		bool running_;
	};

}