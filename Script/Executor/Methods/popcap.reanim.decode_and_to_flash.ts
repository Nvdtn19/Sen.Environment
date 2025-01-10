namespace Sen.Script.Executor.Methods.PopCap.Reanim.DecodeAndToFlash {
	// Using platform

	export type Platform = Kernel.Support.PopCap.ReAnimation.Platform;

	/**
	 * Argument for the current method
	 */

	export interface Argument extends Executor.Base {
		source: string;
		destination?: string;
		platform?: Platform;
	}

	/**
	 * Argument for batch method
	 */

	export interface BatchArgument extends Executor.Base {
		directory: string;
		platform?: Platform;
	}

	/**
	 * Configuration file if needed
	 */

	export interface Configuration extends Executor.Configuration {}

	/**
	 * Detail namespace
	 */

	export namespace Detail {
		/**
		 * Platform supported
		 */

		export const _platform: Array<Kernel.Support.PopCap.ReAnimation.Platform> = [
			'pc',
			'game-console',
			'phone-32',
			'phone-64',
			'tv',
		];
		/**
		 *
		 * Typical Style
		 *
		 */

		export function platform(): Array<[bigint, string, string]> {
			return _platform.map((e, i) => [
				BigInt(i + 1),
				e as string,
				Kernel.Language.get(`popcap.reanim.platform.${e}`),
			]);
		}
	}
	/**
	 * ----------------------------------------------
	 * JavaScript forward method, this method need
	 * to be evaluated during script loading time
	 * ----------------------------------------------
	 */

	export function forward(): void {
		return push_as_module<
			Methods.PopCap.Reanim.DecodeAndToFlash.Argument,
			Methods.PopCap.Reanim.DecodeAndToFlash.BatchArgument,
			Methods.PopCap.Reanim.DecodeAndToFlash.Configuration
		>({
			id: 'popcap.reanim.decode_and_to_flash',
			configuration_file: Home.query(
				'~/Executor/Configuration/popcap.reanim.decode_and_to_flash.json',
			),
			direct_forward(argument: Argument): void {
				is_valid_source(argument, false);
				Console.obtained(argument.source);
				defined_or_default<Argument, string>(
					argument,
					'destination',
					`${Kernel.Path.except_extension(argument.source)}.xfl`,
				);
				check_overwrite(argument as { destination: string }, 'directory');
				Console.output(argument.destination!);
				Console.argument(Kernel.Language.get('popcap.reanim.decode.generic'));
				configurate_or_input(argument, 'platform', Detail.platform());
				clock.start_safe();
				Kernel.Support.PopCap.ReAnimation.Instance.to_flash(
					argument.source,
					argument.destination!,
					argument.platform!,
				);
				clock.stop_safe();
			},
			is_enabled: true,
			configuration: undefined!,
			filter: ['file', /(.+)(\.reanim|\.reanim\.compiled)$/i],
			option: 38n,
		});
	}
}

Sen.Script.Executor.Methods.PopCap.Reanim.DecodeAndToFlash.forward();
