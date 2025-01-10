namespace Sen.Script.Executor.Methods.PopCap.Animation.FromFlashAndEncode {
	/**
	 * Argument for the current method
	 */

	export interface Argument extends Executor.Base {
		source: string;
		destination?: string;
		has_label?: boolean;
	}

	/**
	 * Argument for batch method
	 */

	export interface BatchArgument extends Executor.Base {
		directory: string;
	}

	/**
	 * Configuration file if needed
	 */

	export interface Configuration extends Executor.Configuration {
		resolution: bigint;
	}

	/**
	 * ----------------------------------------------
	 * JavaScript forward method, this method need
	 * to be evaluated during script loading time
	 * ----------------------------------------------
	 */

	export function forward(): void {
		return push_as_module<
			Methods.PopCap.Animation.FromFlashAndEncode.Argument,
			Methods.PopCap.Animation.FromFlashAndEncode.BatchArgument,
			Methods.PopCap.Animation.FromFlashAndEncode.Configuration
		>({
			id: 'popcap.animation.from_flash_and_encode',
			configuration_file: Home.query(
				'~/Executor/Configuration/popcap.animation.from_flash_and_encode.json',
			),
			direct_forward(argument: Argument): void {
				is_valid_source(argument, true);
				Console.obtained(argument.source);
				defined_or_default<Argument, string>(
					argument,
					'destination',
					Kernel.Path.except_extension(argument.source),
				);
				check_overwrite(argument as { destination: string }, 'file');
				Console.output(argument.destination!);
				load_boolean(
					argument,
					'has_label',
					this.configuration,
					Kernel.Language.get('popcap.animation.extract_label'),
				);
				clock.start_safe();
				Kernel.Support.PopCap.Animation.Instance.from_flash(
					argument.source,
					argument.destination!,
					argument.has_label!,
				);
				clock.stop_safe();
			},
			batch_forward(argument: BatchArgument): void {
				return basic_batch(this, argument, true);
			},
			is_enabled: true,
			configuration: undefined!,
			filter: ['directory', /(.+)\.xfl$/i],
			option: 11n,
		});
	}
}

Sen.Script.Executor.Methods.PopCap.Animation.FromFlashAndEncode.forward();
