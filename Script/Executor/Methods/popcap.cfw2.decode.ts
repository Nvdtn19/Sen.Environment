namespace Sen.Script.Executor.Methods.PopCap.CFW2.Decode {
	/**
	 * Argument for the current method
	 */

	export interface Argument extends Executor.Base {
		source: string;
		destination?: string;
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

	export interface Configuration extends Executor.Configuration {}

	/**
	 * ----------------------------------------------
	 * JavaScript forward method, this method need
	 * to be evaluated during script loading time
	 * ----------------------------------------------
	 */

	export function forward(): void {
		return push_as_module<
			Methods.PopCap.CFW2.Decode.Argument,
			Methods.PopCap.CFW2.Decode.BatchArgument,
			Methods.PopCap.CFW2.Decode.Configuration
		>({
			id: 'popcap.cfw2.decode',
			configuration_file: Home.query('~/Executor/Configuration/popcap.cfw2.decode.json'),
			direct_forward(argument: Argument): void {
				is_valid_source(argument, false);
				Console.obtained(argument.source);
				defined_or_default<Argument, string>(
					argument,
					'destination',
					`${Kernel.Path.except_extension(argument.source)}.json`,
				);
				check_overwrite(argument as { destination: string }, 'file');
				Console.output(argument.destination!);
				clock.start_safe();
				Kernel.Support.PopCap.CharacterFontWidget2.decode_fs(
					argument.source,
					argument.destination!,
				);
				clock.stop_safe();
				return;
			},
			is_enabled: true,
			configuration: undefined!,
			filter: ['file', /(.+)\.cfw2$/i],
			option: 17n,
		});
		return;
	}
}

Sen.Script.Executor.Methods.PopCap.CFW2.Decode.forward();
