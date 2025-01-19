#pragma once

#include "kernel/interface/shell.hpp"
#include "kernel/utility/javascript/builder.hpp"

namespace Sen::Kernel::Interface::API {

	
	#pragma region Clock

	namespace Clock {

		template <size_t InstanceCount>
		inline auto register_class(
			JSContext* context,
			const std::array<std::string_view, InstanceCount>& instance_names
		) -> void
		{
			using Clock = Kernel::Clock;
			auto builder = JavaScript::ClassBuilder<Clock>{ context, "Clock" };
			builder.add_constructor<[]() {
				return new Clock{};
			}>()
			.template add_member_function<[](Clock* clock){
				return clock->start_safe();
			}, void>("start_safe")
			.template add_member_function <[](Clock* clock) {
			return clock->stop_safe();
			}, void > ("stop_safe")
			.template add_member_function <[](Clock* clock) {
			return clock->reset();
			}, void> ("reset")
			.template add_member_function <[](Clock* clock) {
			return clock->get_duration();
			}, int64_t> ("get_duration")
			.template add_member_function <[](Clock* clock) {
			return clock->is_started();
			}, bool > ("is_started")
			.template add_member_function <[](Clock* clock) {
			return clock->is_stopped();
			}, bool > ("is_stopped")
			.template add_member_function <[](Clock* clock) {
			return static_cast<double>(clock->get_duration() / 1000.0);
			}, double> ("duration_as_seconds")
			.build(instance_names);
			return;
		}

	}

	#pragma endregion
	
	#pragma region JsonWriter

	namespace JsonWriter {

		template <size_t InstanceCount>
		inline auto register_class(
			JSContext* context,
			const std::array<std::string_view, InstanceCount>& instance_names
		) -> void
		{
			using JsonWriter = Kernel::JsonWriter;
			auto builder = JavaScript::ClassBuilder<JsonWriter>{ context, "JsonWriter" };
			builder.add_constructor<[]() {
				return new JsonWriter{};
			}>()
			.template add_member_function<[](JsonWriter* writer){
				return writer->Clear();
			}, void> ("clear")
			.template add_member_function<[](JsonWriter* writer) {
				return writer->ToString();
			}, std::string>("toString")
			.template add_member_function<[](JsonWriter* writer){
				return writer->WriteStartArray();
			}, void>("writeStartArray")
			.template add_member_function<[](JsonWriter* writer){
				return writer->WriteEndArray();
			}, void>("writeEndArray")
			.template add_member_function<[](JsonWriter* writer){
				return writer->WriteStartObject();
			}, void>("writeStartObject")
			.template add_member_function<[](JsonWriter* writer){
				return writer->WriteEndObject();
			}, void>("writeEndObject")
			.template add_member_function<[](JsonWriter* writer, bool value){
				return writer->WriteBoolean(value);
			}, void, bool>("writeBoolean")
			.template add_member_function<[](JsonWriter* writer){
				return writer->WriteNull();
			}, void>("writeNull")
			.template add_member_function<[](JsonWriter* writer, std::string& property_name){
				return writer->WritePropertyName(property_name);
			}, void, std::string&>("writePropertyName")
			.template add_member_function<[](JsonWriter* writer, std::string& value){
				return writer->WriteValue(value);
			}, void, std::string&>("writeString")
			.template add_member_function<[](JsonWriter* writer, int64_t& value){
				return writer->WriteValue(value);
			}, void, int64_t&>("writeBigInt")
			.template add_member_function<[](JsonWriter* writer, double& value){
				return writer->WriteValue(value);
			}, void, double&>("writeNumber")
			.template add_getter_setter<bool, [](JsonWriter* writer){
				return writer->WriteIndent;
			}, [](JsonWriter* writer, bool& value){
				writer->WriteIndent = value;
			}>("writeIndent").build(instance_names);
			return;
		}

	}

	#pragma endregion

	#pragma region Canvas

	namespace Canvas {

		template <size_t InstanceCount>
		inline auto register_class(
			JSContext* context,
			const std::array<std::string_view, InstanceCount>& instance_names
		) -> void
		{
			using Canvas = canvas_ity::canvas;
			using BrushType = canvas_ity::brush_type;
			auto builder = JavaScript::ClassBuilder<Canvas>{ context, "Canvas" };
			builder.add_constructor<[](int64_t& width, int64_t& height) {
				return new Canvas{ static_cast<int>(width), static_cast<int>(height) };
			}, int64_t&, int64_t&>()
			.template add_member_function<[](Canvas* canvas, float& x, float& y){
				return canvas->scale(x, y);
			}, void, float&, float&> ("scale")
			.template add_member_function<[](Canvas* canvas, float& angle){
				return canvas->rotate(angle);
			}, void, float&> ("rotate")
			.template add_member_function<[](Canvas* canvas, float& x, float& y){
				return canvas->translate(x, y);
			}, void, float&, float&> ("translate")
			.template add_member_function<[](Canvas* canvas, float& a, float& b, float& c, float& d, float& e, float& f){
				return canvas->transform(a, b, c, d, e, f);
			}, void, float&, float&, float&, float&, float&, float&> ("transform")
			.template add_member_function<[](Canvas* canvas, float& a, float& b, float& c, float& d, float& e, float& f){
				return canvas->set_transform(a, b, c, d, e, f);
			}, void, float&, float&, float&, float&, float&, float&> ("set_transform")
			.template add_member_function<[](Canvas* canvas, float& alpha){
				return canvas->set_global_alpha(alpha);
			}, void, float&> ("set_global_alpha")
			.template add_member_function<[](Canvas* canvas, float& red, float& green, float& blue, float& alpha){
				return canvas->set_shadow_color(red, green, blue, alpha);
			}, void, float&, float&, float&, float&> ("set_shadow_color")
			.template add_member_function<[](Canvas* canvas, float& width){
				return canvas->set_line_width(width);
			}, void, float&> ("set_line_width")
			.template add_member_function<[](Canvas* canvas, float& level){
				return canvas->set_shadow_blur(level);
			}, void, float&> ("set_shadow_blur")
			.template add_member_function<[](Canvas* canvas, float& limit){
				return canvas->set_miter_limit(limit);
			}, void, float&> ("set_miter_limit")
			.template add_member_function<[](Canvas* canvas, int32_t& type, float& red, float& green, float& blue, float& alpha){
				return canvas->set_color(static_cast<BrushType>(type), red, green, blue, alpha);
			}, void, int32_t&, float&, float&, float&, float&> ("set_color")
			.template add_member_function<[](Canvas* canvas, int32_t& type, float& start_x, float& start_y, float& end_x, float& end_y){
				return canvas->set_linear_gradient(static_cast<BrushType>(type), start_x, start_y, end_x, end_y);
			}, void, int32_t&, float&, float&, float&, float&> ("set_linear_gradient")
			.template add_member_function<[](Canvas* canvas, int32_t& type, float& start_x, float& start_y, float& start_radius, float& end_x, float& end_y, float& end_radius){
				return canvas->set_radial_gradient(static_cast<BrushType>(type), start_x, start_y, start_radius, end_x, end_y, end_radius);
			}, void, int32_t&, float&, float&, float&, float&, float&, float&> ("set_radial_gradient")
			.template add_member_function<[](Canvas* canvas, int32_t& type, float& offset, float& red, float& green, float& blue, float& alpha){
				return canvas->add_color_stop(static_cast<BrushType>(type), offset, red, green, blue, alpha);
			}, void, int32_t&, float&, float&, float&, float&, float&> ("add_color_stop")
			.template add_member_function<[](Canvas* canvas){
				return canvas->begin_path();
			}, void> ("begin_path")
			.template add_member_function<[](Canvas* canvas, float& x, float& y){
				return canvas->move_to(x, y);
			}, void, float&, float&> ("move_to")
			.template add_member_function<[](Canvas* canvas){
				return canvas->close_path();
			}, void> ("close_path")
			.template add_member_function<[](Canvas* canvas, float& x, float& y){
				return canvas->line_to(x, y);
			}, void, float&, float&> ("line_to")
			.template add_member_function<[](Canvas* canvas, float& control_x, float& control_y, float& x, float& y){
				return canvas->quadratic_curve_to(control_x, control_y, x, y);
			}, void, float&, float&, float&, float&> ("quadratic_curve_to")
			.template add_member_function<[](Canvas* canvas, float& control_1x, float& control_1y, float& control_2x, float& control_2y, float& x, float& y){
				return canvas->bezier_curve_to(control_1x, control_1y, control_2x, control_2y, x, y);
			}, void, float&, float&, float&, float&, float&, float&> ("bezier_curve_to")
			.template add_member_function<[](Canvas* canvas, float& vertex_x, float& vertex_y, float& x, float& y, float& radius){
				return canvas->arc_to(vertex_x, vertex_y, x, y, radius);
			}, void, float&, float&, float&, float&, float&> ("arc_to")
			.template add_member_function<[](Canvas* canvas, float& red, float& green, float& blue, float& alpha){
				return canvas->set_image_color(red, green, blue, alpha);
			}, void, float&, float&, float&, float&> ("set_image_color")
			.template add_member_function<[](Canvas* canvas, float& x, float& y, float& start_angle, float& end_angle, bool counter_clockwise){
				return canvas->arc(x, y, start_angle, end_angle, counter_clockwise);
			}, void, float&, float&, float&, float&, bool> ("arc")
			.template add_member_function<[](Canvas* canvas, float& x, float& y, float& width, float& height){
				return canvas->rectangle(x, y, width, height);
			}, void, float&, float&, float&, float&> ("rectangle")
			.template add_member_function<[](Canvas* canvas){
				return canvas->fill();
			}, void> ("fill")
			.template add_member_function<[](Canvas* canvas){
				return canvas->stroke();
			}, void> ("stroke")
			.template add_member_function<[](Canvas* canvas, float& x, float& y){
				return canvas->is_point_in_path(x, y);
			}, bool, float&, float&> ("is_point_in_path")
			.template add_member_function<[](Canvas* canvas, float& x, float& y, float& width, float& height){
				return canvas->clear_rectangle(x, y, width, height);
			}, void, float&, float&, float&, float&> ("clear_rectangle")
			.template add_member_function<[](Canvas* canvas, float& x, float& y, float& width, float& height){
				return canvas->fill_rectangle(x, y, width, height);
			}, void, float&, float&, float&, float&> ("fill_rectangle")
			.template add_member_function<[](Canvas* canvas, std::shared_ptr<JavaScript::ArrayBuffer>& data, int64_t& bytes){
				return canvas->set_font(reinterpret_cast<unsigned char*>(data->value), static_cast<int>(bytes), static_cast<float>(data->size));
			}, bool, std::shared_ptr<JavaScript::ArrayBuffer>&, int64_t&> ("set_font")
			.template add_member_function<[](Canvas* canvas, std::shared_ptr<JavaScript::ArrayBuffer>& data, int64_t& width, int64_t& height, int64_t& stride, float& x, float& y, float& to_width, float& to_height){
				return canvas->draw_image(reinterpret_cast<unsigned char*>(data->value), static_cast<int>(width), static_cast<int>(height), static_cast<int>(stride), x, y, to_width, to_height);
			}, void, std::shared_ptr<JavaScript::ArrayBuffer>&, int64_t&, int64_t&, int64_t&, float&, float&, float&, float&> ("draw_image")
			.template add_member_function<[](Canvas* canvas, std::shared_ptr<JavaScript::ArrayBuffer>& data, int64_t& width, int64_t& height, int64_t& stride, float& x, float& y){
				return canvas->get_image_data(data->value, static_cast<int>(width), static_cast<int>(height), static_cast<int>(stride), x, y);
			}, void, std::shared_ptr<JavaScript::ArrayBuffer>&, int64_t&, int64_t&, int64_t&, float&, float&> ("get_image_data")
			.template add_member_function<[](Canvas* canvas, std::shared_ptr<JavaScript::ArrayBuffer>& data, int64_t& width, int64_t& height, int64_t& stride, int64_t& x, int64_t& y){
				return canvas->put_image_data(data->value, static_cast<int>(width), static_cast<int>(height), static_cast<int>(stride), static_cast<int>(x), static_cast<int>(y));
			}, void, std::shared_ptr<JavaScript::ArrayBuffer>&, int64_t&, int64_t&, int64_t&, int64_t&, int64_t&> ("put_image_data")
			.template add_member_function<[](Canvas* canvas){
				return canvas->save();
			}, void> ("save")
			.template add_member_function<[](Canvas* canvas){
				return canvas->restore();
			}, void> ("restore").build(instance_names);
			return;
		}

	}

	#pragma endregion
}