namespace Sen.Script.Executor.Methods.PopCap.RSB.Obfuscate {
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
			Methods.PopCap.RSB.Obfuscate.Argument,
			Methods.PopCap.RSB.Obfuscate.BatchArgument,
			Methods.PopCap.RSB.Obfuscate.Configuration
		>({
			id: 'popcap.rsb.obfuscate',
			configuration_file: Home.query('~/Executor/Configuration/popcap.rsb.obfuscate.json'),
			direct_forward(argument: Argument): void {
				is_valid_source(argument, false);
				Console.obtained(argument.source);
				defined_or_default<Argument, string>(
					argument,
					'destination',
					`${argument.source}.bin`,
				);
				check_overwrite(argument as { destination: string }, 'file');
				Console.output(argument.destination!);
				clock.start_safe();
				Support.PopCap.ResourceStreamBundle.Miscellaneous.Obfuscate.process_fs(
					argument.source,
					argument.destination!,
				);
				clock.stop_safe();
			},
			is_enabled: true,
			configuration: undefined!,
			filter: ['file', /(.*)\.(rsb|obb)$/i],
			option: 54n,
		});
	}
}

Sen.Script.Executor.Methods.PopCap.RSB.Obfuscate.forward();
